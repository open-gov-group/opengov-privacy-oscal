Param(
  [string]$SspPath = "oscal/ssp/ssp_template_ropa_full.json"
)

# UUIDs aus euren Component-Definitionen
$IAM = "00000000-0000-0000-0000-00000000c0de"
$DMS = "00000000-0000-0000-0000-00000000d0c2"
$DEL = "00000000-0000-0000-0000-00000000del1"
$BKP = "00000000-0000-0000-0000-00000000bkp1"

if (!(Test-Path $SspPath)) { throw "SSP not found: $SspPath" }
$ssp = Get-Content $SspPath -Raw | ConvertFrom-Json

# Ensure components[]
$components = @()
if ($ssp."system-security-plan"."system-implementation".components) {
  $components = $ssp."system-security-plan"."system-implementation".components
}

function Ensure-Component {
  param($uuid, $type, $title)
  if (-not ($components | Where-Object { $_.uuid -eq $uuid })) {
    $comp = [ordered]@{
      uuid=$uuid; type=$type; title=$title;
      description="Imported from component-definition";
      status=@{ state="operational" }
    }
    $components += $comp
  }
}

Ensure-Component -uuid $DMS -type "software" -title "Dokumentenmanagementsystem"
Ensure-Component -uuid $DEL -type "service"  -title "Deletion Workflow"
Ensure-Component -uuid $BKP -type "service"  -title "Backup/Restore Service"
$ssp."system-security-plan"."system-implementation".components = $components

# Helpers for by-components
function Ensure-ByComponent {
  param($implReq, $componentUuid, $desc)
  foreach ($stmt in ($implReq.statements | ForEach-Object { $_ })) {
    if (-not $stmt."by-components") { $stmt."by-components" = @() }
    $exists = $stmt."by-components" | Where-Object { $_."component-uuid" -eq $componentUuid }
    if (-not $exists) {
      $stmt."by-components" += @{
        "component-uuid" = $componentUuid;
        "uuid" = [guid]::NewGuid().ToString();
        "description" = $desc
      }
    }
  }
}

# Map: control-id -> (component, description)
$map = @{
  "B1-1" = @(@{ c=$DMS; desc="DMS stellt publizierte Hinweise & Aktenplankontext bereit." })
  "B1-2" = @(@{ c=$DMS; desc="DMS erzwingt Zweckmetadaten / Mandantentrennung." })
  "B1-6" = @(@{ c=$DMS; desc="DMS nutzt WORM/Hash & Versionierung." })
  "B1-8" = @(@{ c=$DMS; desc="DMS liefert Audit-Logs & Nachweise." })
  "B1-10"= @(@{ c=$IAM; desc="IAM/SPOC für Betroffenenrechte (SLA, AuthN/Z)." })
  "B1-12"= @(@{ c=$DEL; desc="Lösch-Engine erzeugt Erasure Proofs." })
  "B1-14"= @(@{ c=$IAM; desc="Export-Endpunkte über IAM/Portal." })
  "B1-20"= @(@{ c=$BKP; desc="Backup/Restore erfüllt RTO/RPO & Tests." })
}

$implReqs = $ssp."system-security-plan"."control-implementation"."implemented-requirements"
foreach ($ir in $implReqs) {
  $cid = $ir."control-id"
  if ($map.ContainsKey($cid)) {
    foreach ($m in $map[$cid]) {
      Ensure-ByComponent -implReq $ir -componentUuid $m.c -desc $m.desc
    }
  }
}

# write back
$ssp."system-security-plan".metadata."last-modified" = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$ssp | ConvertTo-Json -Depth 50 | Set-Content $SspPath -Encoding UTF8

Write-Host "SSP patched successfully."
