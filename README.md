# Musician Graph

## Overview

The aim of this project is to create an RDF/OWL graph linking data about musicians, bands, instruments, and associated
locations together.

It begins by retrieving information about groups and musicians from [DBPedia](https://www.dbpedia.org/). Eventually, the goal is to also incorporate related
data from [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page), [GeoNames](https://www.geonames.org/), [MusicBrainz](https://musicbrainz.org/) and perhaps other 
sources into a convenient, one-stop shop for musician-related information.

The `dev` branch reflects the latest state-of-the-art for this project.

## General Layout

The graph revolves around musicians and the groups that they are affiliated with, if any. Additional information relating to these groups is also to be included, some of it coming 
from other knowledge graphs. The primary basis of the graph draws on DBPedia for its information. The look of the current graph is likely to change considerably in the coming weeks.

The [SPARQL](https://www.w3.org/TR/sparql11-query/) queries used in the project at this time assume SPARQL v1.1.

At this time, a local [Fuseki](https://jena.apache.org/documentation/fuseki2/) running in a [Docker](https://www.docker.com/) container is required to run this project.

## Running the Application

To run the application in its current state, stand up a local Fuseki server using the [Atomgraph](https://hub.docker.com/r/atomgraph/fuseki) Fuseki Docker container, using the load from data set command that reads like: 

```
docker run --rm -p 3030:3030 -v $(pwd):/usr/share/data atomgraph/fuseki --file=musician_graph.owl /ds
```

This example line uses the `musician_graph.owl` ontology file, but do replace this with the name of your ontology file, should it be named differently for any reason.
Also, do ensure that at line 9 of `constructor.hy`, you change the file path in the first `PREFIX` declaration to match the path of where your `.owl` file is.

### Why Hy?

Why [Hy](https://hylang.org/)? Why not? Seriously though, I enjoy the power and flexibility of lisps and lisp-like languages. Having access to the entire [Python](https://www.python.org/) 
ecosystem, as well as the language's interoperability with Python is a considerable boon for this project.
