# Roadmap for 2.0

## overhaul serialize/pretty printing API

* https://github.com/sparklemotion/nokogiri/issues/530
  XHTML formatting can't be turned off

* https://github.com/sparklemotion/nokogiri/issues/415
  XML formatting should be no formatting


## overhaul and optimize the SAX parsing

* see fairy wing throwdown - SAX parsing is wicked slow.


## Node should not be Enumerable; and should have a better attributes API

* https://github.com/sparklemotion/nokogiri/issues/679
  Mixing in Enumerable has some unintended consequences; plus we want to improve the attributes API

* (closed) https://github.com/sparklemotion/nokogiri/issues/666
  Some ideas for a better attributes API?


## improve CSS query parsing

* https://github.com/sparklemotion/nokogiri/issues/528
  support `:not()` with a nontrivial argument, like `:not(div p.c)`

* https://github.com/sparklemotion/nokogiri/issues/451
  chained :not pseudoselectors

* better jQuery selector support:
  * https://github.com/sparklemotion/nokogiri/issues/621
  * https://github.com/sparklemotion/nokogiri/issues/342
  * https://github.com/sparklemotion/nokogiri/issues/628
  * https://github.com/sparklemotion/nokogiri/issues/652
  * https://github.com/sparklemotion/nokogiri/issues/688

* https://github.com/sparklemotion/nokogiri/issues/394
  nth-of-type is wrong, and possibly other selectors as well

* https://github.com/sparklemotion/nokogiri/issues/309
  incorrect query being executed

* https://github.com/sparklemotion/nokogiri/issues/350
  :has is wrong?


## DocumentFragment

* there are a few tickets about searches not working properly if you
  use or do not use the context node as part of the search.
  - https://github.com/sparklemotion/nokogiri/issues/213
  - https://github.com/sparklemotion/nokogiri/issues/370
  - https://github.com/sparklemotion/nokogiri/issues/454
  - https://github.com/sparklemotion/nokogiri/issues/572


## Better Syntax for custom XPath function handler

* https://github.com/sparklemotion/nokogiri/pull/464


## Better Syntax around Node#xpath and NodeSet#xpath

* look at those methods, and use of Node#extract_params in Node#{css,search}
  * we should standardize on a hash of options for these and other calls
* what should NodeSet#xpath return?
  * https://github.com/sparklemotion/nokogiri/issues/656

## Encoding

We have a lot of issues open around encoding. How bad are things?
Would it help if we deprecated support for Ruby 1.8.7? Somebody who
knows encoding well should head this up.

* Extract EncodingReader as a real object that can be injected
  https://groups.google.com/forum/#!msg/nokogiri-talk/arJeAtMqvkg/tGihB-iBRSAJ


## Reader

It's fundamentally broken, in that we can't stop people from crashing
their application if they want to use object reference unsafely.
