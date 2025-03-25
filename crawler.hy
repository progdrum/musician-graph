(import yaml
        requests
        re [sub]
        hyrule [pprint]
        owlready2 *)
(require hyrule.argmove [->])

(setv endpoints {"dbpedia-ep" "https://dbpedia.org/sparql"
                 "wikidata-ep" "https://query.wikidata.org/bigdata/namespace/wdq/sparql"})

(setv onto (.load (get-ontology "file:///home/sean/Code/musician-graph/musician_network.owl")))

(defn get-query [qgrp qname]
  "Retrieve the named query in the given group."
  (with [qfile (open "queries.yaml")]
    (let [queries (yaml.safe-load qfile)]
      (get queries qgrp qname))))

(defn send-query [qu kb]
  "Send a query to the chosen knowledge base"
  (let [endpoint (get endpoints f"{kb}-ep")
        resp (requests.get endpoint :params {"query" qu
                                             "format" "json"})]
    (cond
      (= kb "dbpedia") (get (resp.json) "results" "bindings")
      (= kb "wikidata") (raise (NotImplementedError
                                "Response handling for Wikidata has not been implemented yet."))
      True (raise (ValueError f"Invalid KB {kb} specified.")))))

(defn titleize [title-str]
  "Convert an entity string from DBPedia to a good local title format."
  (.replace (.title title-str) " " "_"))

(defn get-genre-names-dbp [gresp]
  "Take the response from a DBPedia query for genres with names and collect the names in a list."
  (lfor genre gresp (titleize (get genre "name" "value"))))

(defn add-genres [ontology]
  "Add genres to the ontology."
  (let [genres
        (-> (get-query "basic" "genres")
            (send-query "dbpedia")
            (get-genre-names-dbp))]
    (for [gname genres]
      (ontology.Genre gname))))

(defn add-groups [ontology genre]
  "Add groups to the ontology, associating them with the genres to which they belong."
  (let [gglst
        (-> (.format (get-query "basic" "bands_by_genre")
                     :genre genre)
            (send-query "dbpedia"))]
    (for [entry gglst]
      (let [genre-name
            (sub r"_\\([A-Za-z_]+\\)" "" (titleize (get (.split (get entry "band" "value") "/") -1)))
            genre-lst
            (lfor gstr
                  (.split (get entry "genres" "value") ";")
                  (ontology.Genre (titleize (get (.split gstr "/") -1))))]
        (try
          (ontology.Group genre-name :namespace ontology :has-genre genre-lst)
          (except [e AttributeError]
                  (print f"The error is {e}")
                  (with [errfile (open "failed_genres.txt" "a")]
                    (errfile.write f"Could not sync band {genre-name} with genres {genre-lst} because {e}.\n"))
                  (continue)))))))

(defn crawl-data [kb ontology]
  "Function prototype for functional method to crawl music data"
  (add-genres ontology)
  (add-groups ontology "Stoner_rock"))

(add-groups onto "Stoner_rock")

(let [bands (lfor indiv (onto.individuals) :if (in onto.Group indiv.is-a) indiv)]
  (pprint bands)
  (print f"There are {(len bands)} bands."))

(defn prlst [expr]
  "Pretty-print a list from an expression that returns a generator."
  (pprint (list expr)))

;; (setv onto (.load (get-ontology "file:///home/sean/Code/musician-graph/musician_network.owl")))

;; Save!
(onto.save :file "/home/sean/Code/musician-graph/musician_network.owl" :format "rdfxml")
