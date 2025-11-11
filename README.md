# Musician Graph

## Overview

The aim of this project is to create an RDF/OWL graph linking data about musicians, bands, instruments, and associated
locations together.

It begins by retrieving information about groups and musicians from [DBPedia](https://www.dbpedia.org/). Eventually, the goal is to also incorporate related
data from [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page), [GeoNames](https://www.geonames.org/), and perhaps other sources into a convenient, one-stop shot for musician-related information.

## Architecture

At this point, very simplistic. The OWL file is served locally by Fuseki, interacted with by Hy with Python's `requests` library to query it. Using a
large `CONSTRUCT` query to generate the graph and insert it into the OWL graph.
