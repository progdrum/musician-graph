(import rdflib)
(import requests)
(import owlready2 *)
(require hyrule.argmove [->])


(setv cquery #[[PREFIX : <file:///home/sean/Code/musician-graph/musician_network.owl#>
                PREFIX dbo: <http://dbpedia.org/ontology/>
                PREFIX dbr: <http://dbpedia.org/resource/>
                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                CONSTRUCT {?localBand a :Group .
                           ?localMusician a :Musician . 
                           ?localFormerMusician a :Musician .
                           ?localGenre a :Genre .
                           ?localBand :has_genre ?localGenre .
                           ?localBand :has_member ?localMusician .
                           ?localBand :had_member ?localFormerMusician .}
                WHERE {SERVICE <https://dbpedia.org/sparql> {
                        ?band dbo:genre dbr:Stoner_rock . 
                        ?band dbo:genre ?allGenres .                                    
                        ?band dbo:bandMember ?cmember .
                        ?band dbo:formerBandMember ?fmember .}
                       BIND(IRI(CONCAT(STR(:), "group_", REPLACE(STR(?band), ".*/(.*)", "$1"))) AS ?localBand)
                       BIND(IRI(CONCAT(STR(:), "musician_", REPLACE(STR(?cmember), ".*/(.*)", "$1"))) AS ?localMusician)
                       BIND(IRI(CONCAT(STR(:), "musician_", REPLACE(STR(?fmember), ".*/(.*)", "$1"))) AS ?localFormerMusician)
                       BIND(IRI(CONCAT(STR(:), "genre_", REPLACE(STR(?allGenres), ".*/(.*)", "$1"))) AS ?localGenre)}]])

(let [results (requests.get "http://localhost:3030/ds/sparql"
                            :params {"query" cquery "format" "xml"})
      ;; Need to fully qualify "Graph" in Hy or it will throw a dumb error!
      g (-> (rdflib.Graph)
            (.parse "file:///home/sean/Code/musician-graph/musician_network.owl" 
                    :format "xml"))
      result-graph (rdflib.Graph)]
  (for [triple (g.query cquery)]
    (result-graph.add triple))
  (for [triple (g.query cquery)]
    (g.add triple))
  (.serialize g :destination "musician_network.owl" :format "xml"))
