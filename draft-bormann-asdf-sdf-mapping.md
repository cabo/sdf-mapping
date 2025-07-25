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
  W3C.wot-thing-description11: wot-td

entity:
        SELF: "[RFC-XXXX]"

--- abstract

[^intro-]

[^intro-]:
    The Semantic Definition Format (SDF) is a format for domain experts to
    use in the creation and maintenance of data and interaction models
    that describe Things, i.e., physical objects that are available
    for interaction over a network.
    It was created as a common language for use
    in the development of the One Data Model liaison organization (OneDM)
    models.  Tools convert this format to database formats and other
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

{::boilerplate bcp14-tagged-bcp14}

# Overview

An SDF mapping file provides augmentation information for one or more
SDF models.
Its main contents is a map from SDF name references ({{Section 4.3 of
-sdf}}) to a set of qualities.

When processing the mapping file together with one or more SDF
models, these qualities are added to the SDF model at the
referenced name, as in a merge-patch operation {{-merge-patch}}.
Note that this is somewhat similar to the way `sdfRef` ({{Section 4.4 of -sdf}}) works, but in a
mapping file the arrows point in the inverse direction (from the
augmenter to the augmented).

## Example Model 1 (ecosystem: IPSO/OMA) {#example1}

An example for an SDF mapping file is given in {{code-example1}}.
This mapping file is meant to attach to an SDF specification published
by OneDM, and to add qualities relevant to the IPSO/OMA ecosystem.
[^namespace-note]

[^namespace-note]: \\
    Note that this example uses namespaces to identify elements of the
    referenced specification(s), but has un-namespaced quality names.
    These two kinds of namespaces are unrelated in SDF, and a more
    robust example may need to make use of Quality Name Prefixes
    as defined in {{Section 2.3.3-3 of -sdf}} (independent of a potential
    feature to add namespace references to definitions that are not
    intended to go into the default namespace — these are SDF
    definition namespaces and not quality namespaces, which are one
    meta-level higher).

* Start of a mapping file for certain OneDM playground models:

~~~ sdf
info:
  title: IPSO ID mapping
namespace:
  onedm: https://onedm.org/models
defaultNamespace: onedm
map:
  - target: "#/sdfObject/Digital_Input"
    patch:
      id: 3200
  - target: "#/sdfObject/Digital_Input/sdfProperty/Digital_Input_State"
    patch:
      id: 5500
  - target: "#/sdfObject/Digital_Input/sdfProperty/Digital_Input_Counter"
    patch:
      id: 5501
~~~
{: #code-example1 check="json" pre="yaml2json" title="A simple example of an SDF mapping file"}

## Example Model 2 (ecosystem: W3C WoT) {#example2}

This example shows a translation of a hypothetical W3C WoT Thing Model
(as defined in Section 10 of {{-wot-td}})
into an SDF model plus a mapping file to catch Thing Model attributes
that don't currently have SDF qualities defined (namely, `titles` and
`descriptions` members used for internationalization).

A second mapping file is more experimental in that it captures
information that is actually instance-specific,
in this case a `forms` member that binds the `status` property to an
instance-specific CoAP resource.
[^td-note]

The form really should be part of the class level; defining the entire
form instead of just the link in the instance information is a
symptom of not yet getting the class/instance boundary right.

[^td-note]: \\
    Namespaces are all wrong in this example.

* The input: WoT Thing Model

~~~ json
{
    "@context": "https://www.w3.org/2022/wot/td/v1.1",
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
            "readOnly": true,
            "forms": [
              {
                "href": "coap://example.org/status"
              }
            ]
        }
    }
}
~~~
{: #code-wot-input title="Input: WoT Thing Model"}

* The output: SDF model

~~~ sdf
info:
  title: Lamp Thing Model
namespace:
  wot: http://www.w3.org/ns/td
defaultNamespace: wot
sdfObject:
  LampThingModel:
    label: Lamp Thing Model
    sdfProperty:
      status:
        description: Current status of the lamp
        writable: false
        type: string
~~~
{: #code-wot-output1 check="json" pre="yaml2json" title="Output 1: SDF Model"}

* The other output: SDF mapping file for class information

~~~ sdf
info:
  title: 'Lamp Thing Model: WoT TM mapping'
namespace:
  wot: http://www.w3.org/ns/td
defaultNamespace: wot
map:
  - target: "#/sdfObject/LampThingModel"
    patch:
      titles:
        en: Lamp Thing Model
        de: Thing Model für eine Lampe
  - target: "#/sdfObject/LampThingModel/sdfProperty/status"
    patch:
      descriptions:
        en: Current status of the lamp
        de: Aktueller Status der Lampe
~~~
{: #code-wot-output2 check="json" pre="yaml2json" title="Output 2: SDF Mapping File"}

* A third output: SDF mapping file for Protocol Bindings

~~~ sdf
info:
  title: 'Lamp Thing Model: WoT TM Protocol Binding'
namespace:
  wot: http://www.w3.org/ns/td
defaultNamespace: wot
map:
  - target: "#/sdfObject/LampThingModel/sdfProperty/status"
    patch:
      forms:
      - href: coap://example.org/status
~~~
{: #code-wot-output3 check="json" pre="yaml2json" title="Output 3: SDF Mapping File for Protocol Bindings"}


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

The JSON pointer that is used on the left-hand side of the map can
point to a JSON map in the SDF model to be augmented by adding or
replacing map entries.
If necessary, the JSON map is created at the position indicated with
the contents of right-hand side of the map [^example].
Alternatively, the JSON pointer can point to an array (also possibly
created if not existing before) and add an element to that array by
using the "`‑`" syntax introduced in the penultimate paragraph of
{{Section 4 of -pointer}}.

[^example]: (add examples)

# Augmentation Mechanism

<!-- TODO: Discuss used terminology -->
An SDF model and a compatible mapping file can be combined to create
an _augmented_ SDF model.
(This process can be repeated with multiple mapping files by using the
outcome of one augmentation as the input of the next one.)
As augmentation is not equal to instantiation, augmented SDF models
are still abstract in nature, but are enriched with ecosystem-specific
information.

{:aside}
>
Note that it might be necessary to specify an augmentation mechanism for instance descriptions as well at a later point in time, once it has been decided what the instance description format might look like and whether such a format is needed.

The augmentation mechanism is related to the resolution mechanism
defined in {{Section 4.4 of -sdf}}, but fundamentally different:

Instead of a model file reaching out to other model files and
integrating aspects into itself via `sdfRef` (*pull* approach), the
mapping file *pushes* information into a new copy of a specific given
SDF model.
The original SDF model does not need to know which mapping files it
will be used with and can be used with several such mapping files
independently of each other.

An augmented SDF model is produced from two inputs: An SDF model and a compatible mapping file, i.e. every JSON pointer within the keys of the mapping file's `map` object points to a location that already exists within the SDF model.
To perform the augmentation, a processor needs to create a copy of the original SDF model.
It then iterates over all entries within the mapping file's `map` object \[in an order to be specified; probably lexicographical].
During each iteration, the processor first obtains a reference to the target referred to by the JSON pointer contained an entry's key.
This reference is then used as the `Target` argument of the JSON Merge Patch algorithm {{-merge-patch}} and the entry's value as the `Patch` argument; the target is replaced with the result of the merge-patch.

Once the iteration has finished, the processor returns the resulting augmented SDF model.
Should the resolution of a JSON pointer or an application of the JSON Merge Patch algorithm fail, an error is thrown instead.

{:aside}
>
Note that, in contrast to an array, the entries of a JSON object are considered unordered, which means that the sequence in which the `map` entries are applied is implementation-dependent.
For this reason, we need to make sure that the contents of mapping
files can be applied independently of each other.
(We need to understand the onus in
ensuring this that is put on author of a mapping file.)
>
The problem can be "avoided" by changing the data structure used by the `map` quality to an array of objects to ensure a deterministic application order.
This would essentially put most of the onus on the author of a mapping
file to get any order dependencies right.
More preferable would be to ensure the entries in the mapping file can
be applied independently and in any order.
More discussion and implementation experience is required.

An example for an augmented SDF model can be seen in {{code-augmented-sdf-model}}.
This is the result of applying the WoT-specific mapping file from {{code-wot-output2}} to the SDF model shown in {{code-wot-output1}}.
This augmented SDF model is one step away from being converted to a WoT Thing Model or Thing Description,
which requires some information that cannot be provided in an SDF
model that is limited to the vocabulary defined in the SDF base specification.

<!-- TODO: Prefix WoT-specific qualities with wot:? -->
~~~ sdf
info:
  title: Lamp Thing Model
namespace:
  wot: http://www.w3.org/ns/td
defaultNamespace: wot
sdfObject:
  LampThingModel:
    label: Lamp Thing Model
    titles:
      en: Lamp Thing Model
      de: Thing Model für eine Lampe
    sdfProperty:
      status:
        description: Current status of the lamp
        descriptions:
          en: Current status of the lamp
          de: Aktueller Status der Lampe
        writable: false
        type: string
~~~
{: #code-augmented-sdf-model check="json" pre="yaml2json" title="An SDF model that has been augmented with WoT-specific vocabulary."}

{:aside}
>
Since the pair of an SDF model and a mapping file is equivalent in
semantics to the augmented model created from the two, there is no
fundamental difference between specifying aspects in the SDF model or
leaving them in a mapping file.
Also, parts of an ecosystem-specific vocabulary may in fact be
mappable to the SDF base vocabulary.
Therefore, developing the mapping between SDF and an ecosystem
requires careful consideration which of the features should be available
to other ecosystems and therefore should best be part of the common
SDF model, and which are best handled in a mapping file specific to the
ecosystem.

<!-- TODO: Also needs to take NIPC into account somewhere -->

## Logging Augmentation

Since an augmented model is not fundamentally different from any other
SDF model, it may be necessary to trace the provenance of the
information that flowed into it, e.g., in the info block.
For this purpose, a new quality called `augmentationLog` is introduced
that contains an array of URIs pointing to the mapping files that have been
used to augment the original SDF file (which can also be indicated via
the `originalSdfModel` quality).
These additional qualities allow for reproducing the augmentation process.

For logging while performing an augmentation, the processor has to perform
the following steps:

<!-- TODO: This algorithm probably needs to be reworked or at least reformatted. -->
1. If the `info` block is not present in the model that is being augmented,
  the processor creates it.
2. If the `info` block does not contain an `augmentationLog` quality, the processor
  performs the following steps:
    1. If the `originalSdfModel` quality is not present in the `info`
       block, the processor adds it with a URI that can be used to
       access the SDF model that is currently being augmented as its
       value.
    2. The processor creates the `augmentationLog` quality with an
       array containing URIs that can be used to access the current
       mapping file as its sole item.
2. Otherwise, if `augmentationLog` does not contain an array, stop and
   throw an error.
3. Otherwise, the processor adds a URI that can be used to access the
   current mapping file to the array of the `augmentationLog` quality.

<!-- [^logging] -->

~~~ sdf
info:
  title: Augmented SDF model with augmentation log.
  augmentationLog:
    - https://example.org/sdf-mapping-file-1
    - https://example.org/sdf-mapping-file-2
  originalSdfModel: https://example.org/original-sdf-model
# TODO: Do we need more information here?
~~~
{: #augmentation-log check="json" pre="yaml2json" title="An augmented SDF model with an augmentation log and information regarding the original SDF model."}

[^logging]: A convention for "logging" the augmentation steps that
    went into an augmented model needs to be further fleshed out.
    (An array in the info block that receives additions from a mapping
    file using the "`‑`" pointer syntax may be a good receptacle for
    receiving information about multiple augmentations.)

IANA Considerations {#iana}
===================

Media Type
-----------

IANA is requested to add the following Media-Type to the "Media Types" registry.

| Name             | Template                     | Reference             |
|------------------|------------------------------|-----------------------|
| sdf-mapping+json | application/sdf-mapping+json | RFC XXXX, {{media-type}} |
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
: Tools for data and interaction modeling that describes Things, i.e.,
   physical objects that are available for interaction over a network

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

(TBD: After any future additions, check if we need any.)


Security Considerations {#seccons}
=======================

Some wider issues are discussed in {{-seccons}}.

(Specifics: TBD.)


--- back

{::include-all lists.md}

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

