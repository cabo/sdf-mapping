---
v: 3
coding: utf-8

title: >
  Semantic Definition Format (SDF): Mapping files
abbrev: SDF Mapping
docname: draft-bormann-asdf-sdf-mapping-latest

category: std
submissiontype: IETF
consensus: true

area: Applications
workgroup: ASDF
keyword: Internet-Draft

author:
  - name: Carsten Bormann
    org: Universität Bremen TZI
    orgascii: Universitaet Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org
    role: editor
  - name: Jan Romann
    org: Universität Bremen
    email: jan.romann@uni-bremen.de
    country: Germany

venue:
  group: A Semantic Definition Format for Data and Interactions of Things (asdf)
  mail: asdf@ietf.org
  github: cabo/sdf-mapping

normative:
  RFC6901: pointer
  RFC8610: cddl
  RFC7396: merge-patch
#  RFC3986: uri
#  W3C.NOTE-curie-20101216: curie
#  RFC0020: ascii
  I-D.ietf-asdf-sdf: sdf
informative:
  RFC8576: seccons

entity:
        SELF: "[RFC-XXXX]"

--- abstract

[^intro-]

[^intro-]:
    The Semantic Definition Format (SDF) is a format for domain experts to
    use in the creation and maintenance of data and interaction models in
    the Internet of Things.  It was created as a common language for use
    in the development of the One Data Model liaison organization (OneDM)
    definitions.  Tools convert this format to database formats and other
    serializations as needed.

    An SDF specification often needs to be augmented by additional
    information that is specific to its use in a particular ecosystem or
    application.
    SDF mapping files provide a mechanism to represent this
    augmentation.

--- middle


# Introduction

<!-- Just copying the abstract, for now... -->

[^intro-]

## Terminology and Conventions

The definitions of {{-sdf}} apply.

<!-- XXX -->

The term "byte" is used in its now-customary sense as a synonym for
"octet".

{::boilerplate bcp14-tagged}

# Overview

An SDF mapping file provides augmentation information for one or more
SDF definitions.
Its main contents is a map from SDF name references ({{Section 4.3 of
-sdf}}) to a set of qualities.

When processing the mapping file together with one or more SDF
definitions, these qualities are added to the SDF definition at the
referenced name, as in a merge-patch operation {{-merge-patch}}.
Note that this is somewhat similar to the way sdfRef ({{Section 4.4 of -sdf}}) works, but in a
mapping file the arrows point in the inverse direction (from the
augmenter to the augmented).

## Example Definition 1 (ecosystem: IPSO/OMA) {#example1}

An example for an SDF mapping file is given in {{code-example1}}.
This mapping file is meant to attach to an SDF specification published
by OneDM, and to add qualities relevant to the IPSO/OMA ecosystem.
[^namespace-note]

[^namespace-note]: \\
    Note that this example uses namespaces to identify elements of the
    referenced specification(s), but has un-namespaced quality names.
    These two kinds of namespaces are probably unrelated, and we may
    need to add quality namespacing to SDF (independent of a potential
    feature to add namespace references to definitions that are not
    intended to go into the default namespace — these are SDF
    definition namespaces and not quality namespaces, which are one
    meta-level higher).

* Start of mapping file for certain OneDM playground models:

~~~ json
{
  "info": {
    "title": "IPSO ID mapping"
  },
  "namespace": {
    "onedm": "https://onedm.org/models"
  },
  "defaultNamespace": "onedm",
  "map": {
    "#/sdfObject/Digital_Input": {
      "id": 3200
    },
    "#/sdfObject/Digital_Input/sdfProperty/Digital_Input_State": {
      "id": 5500
    },
    "#/sdfObject/Digital_Input/sdfProperty/Digital_Input_Counter": {
      "id": 5501
    }
  }
}
~~~
{: #code-example1 title="A simple example of an SDF mapping file"}

## Example Definition 2 (ecosystem: W3C WoT) {#example2}

This example shows a translation of a hypothetical W3C WoT Thing Model
into an SDF model plus a mapping file to catch Thing Model attributes
that don't currently have SDF qualities defined.
[^td-note]

[^td-note]: \\
    The example probably would be more useful with, say, protocol
    bindings.
    This is left for a future version of this example, and/or a
    future specification that specifically addresses how to map Thing
    Models into SDF.
    \\
    (There is also the separate requirement to transform a Thing Description
    into the kind of information that can be represented in SDF plus
    instance information, such as IP addresses or specific node
    names.)
    \\
    Finally, namespaces are all wrong in this example.

* The input: WoT Thing Model

~~~json
{
    "@context": ["http://www.w3.org/ns/td"],
    "@type" : "tm:ThingModel",
    "title": "Lamp Thing Model",
    "titles": {
      "en": "Lamp Thing Model",
      "de": "Thing Model für eine Lampe"
    },
    "properties": {
        "status": {
            "description": "Current status of the lamp",
            "descriptions": {
              "en": "Current status of the lamp",
              "de": "Aktueller Status der Lampe"
            },
            "type": "string",
            "readOnly": true
        }
    }
}
~~~
{: #code-wot-input title="Input: WoT Thing Model"}

* The output: SDF model

~~~json
{
  "info": {
    "title": "Lamp Thing Model"
  },
  "namespaces": {
    "wot": "http://www.w3.org/ns/td"
  },
  "defaultNamespace": "wot",
  "sdfObject": {
    "LampThingModel": {
      "label": "Lamp Thing Model",
      "sdfProperty": {
        "status": {
          "description": "Current status of the lamp",
          "writable": false,
          "type": "string"
        }
      }
    }
  }
}
~~~
{: #code-wot-output1 title="Output 1: SDF Model"}

* The other output: SDF mapping file

~~~json
{
  "info": {
    "title": "Lamp Thing Model: WoT TM mapping"
  },
  "namespace": {
    "wot": "http://www.w3.org/ns/td"
  },
  "defaultNamespace": "wot",
  "map": {
    "#/sdfObject/LampThingModel": {
      "titles": {
        "en": "Lamp Thing Model",
        "de": "Thing Model für eine Lampe"
      }
    },
    "#/sdfObject/LampThingModel/sdfProperty/status": {
      "descriptions": {
        "en": "Current status of the lamp",
        "de": "Aktueller Status der Lampe"
      }
    }
  }
}
~~~
{: #code-wot-output2 title="Output 2: SDF Mapping File"}


# Formal Syntax of SDF mapping files {#syntax}

An SDF mapping file has three optional components that are taken
unchanged from SDF: The info block, the namespace declaration, and the
default namespace.
The mandatory fourth component, the "map", contains the mappings from
an SDF name reference (usually a namespace and a JSON pointer) to a
nested map providing a set of qualities to be merged in at the site
identified in the name reference.

{{mapping-cddl}} describes the syntax of SDF mapping files using CDDL {{-cddl}}.

~~~ cddl
{::include mapping.cddl}
~~~
{: #mapping-cddl title="CDDL definition of SDF mapping file"}


IANA Considerations {#iana}
===================

Media Type
-----------

IANA is requested to add the following Media-Type to the "Media Types" registry.

| Name     | Template             | Reference                 |
| sdf-mapping+json | application/sdf-mapping+json | RFC XXXX, {{media-type}}  |
{: #new-media-types title="A media type for SDF mapping files" align="left"}

[^to-be-removed]

[^to-be-removed]: RFC Editor: please replace RFC XXXX with this RFC number and remove this note.

{:compact}
Type name:
: application

Subtype name:
: sdf-mapping+json

Required parameters:
: none

Optional parameters:
: none

Encoding considerations:
: binary (JSON is UTF-8-encoded text)

Security considerations:
: {{seccons}} of RFC XXXX

Interoperability considerations:
: none

Published specification:
: {{media-type}} of RFC XXXX

Applications that use this media type:
: Tools for data and interaction modeling in the Internet of Things

Fragment identifier considerations:
: A JSON Pointer fragment identifier may be used, as defined in
  {{Section 6 of RFC6901}}.

Person & email address to contact for further information:
: ASDF WG mailing list (asdf@ietf.org),
  or IETF Applications and Real-Time Area (art@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration:
: no



Registries
----------

(TBD: After future additions, check if we need any.)


Security Considerations {#seccons}
=======================

Some wider issues are discussed in {{-seccons}}.

(Specifics: TBD.)


--- back

# Acknowledgements
{: numbered="no"}


This draft is based on discussions in the Thing-to-Thing Research
Group (T2TRG) and the SDF working group.  Input for {{example1}} was provided by {{{Ari Keränen}}}.

<!--  LocalWords:  SDF namespace defaultNamespace instantiation OMA
 -->
<!--  LocalWords:  affordances ZigBee LWM OCF sdfObject sdfThing
 -->
<!--  LocalWords:  idempotency Thingness sdfProperty sdfEvent sdfRef
 -->
<!--  LocalWords:  namespaces sdfRequired Optionality sdfAction
 -->
<!--  LocalWords:  sdfProduct dereferenced dereferencing atomicity
 -->
<!--  LocalWords:  interworking
 -->

