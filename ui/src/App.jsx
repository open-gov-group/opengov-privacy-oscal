const [catalogList, setCatalogList] = useState([]);
const [catalogSel, setCatalogSel] = useState(null);

useEffect(() => {
  fetch("https://raw.githubusercontent.com/open-gov-group/opengov-privacy-oscal/main/oscal/catalogs.json")
    .then(r=>r.json()).then(list => {
      setCatalogList(list);
      if (!catalogSel) setCatalogSel(list[0]);
    }).catch(()=>{});
}, []);

{/* im Headerbereich */}
{catalogList.length>0 && (
  <div className="text-xs">
    <label className="mr-2">Catalog:</label>
    <select
      className="border rounded-md px-2 py-1"
      value={catalogSel?.id || ""}
      onChange={(e)=> setCatalogSel(catalogList.find(x=>x.id===e.target.value))}
    >
      {catalogList.map(c=> <option key={c.id} value={c.id}>{c.title} {c.version}</option>)}
    </select>
  </div>
)}
