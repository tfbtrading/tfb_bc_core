
# TFB Trading Core Application

## Dependencies

Comunication Log Common Library

## Applications which depend on this

This library is a 'dependency' for an advanced warehouse shipment library, non-conformance management and advanced reporting library (with a dependancy on ForNav). 

## Notes about code library

This application is in production use. It is not used by anyone and has not been 'hardened' for use across multiple customers. For productivity in this context it contains
no test libraries and does not in pretend to be an example of development best practice or patterns.

## Notes about the author

Whilst once upon a time in the 1990's I was a software engineer, then technology strategy, then software product manage; I am now a director with  a day job of running an food import and distribution business. All coding has been done
on the side as a hobby and as a way to give my business some key advantages in business process without the prohibitive (and reasonable in many contexts) costs of using a third party
consultancy. 

All errors are mine.

# Why is this repository shared

At times I have been very critical of the Microsoft Dynamics Business Central product team. I believe they are making too little progress and putting too little thought
into the improvement of the product. However, they are relatively transparent and share their code. So I will share that spirit. The code in this repository in worth hundreds of hours
of coding by an amateur over a couple of years.  Feel free to copy, co-opt, criticise or even offer improvements.

# Major areas of functionality

Not all areas of this code are relevant to companies outside the Food Import / Distribution business. However, much of it is actually fixes or improvements for base functionality
in the platform. Some is wholesale lifted from suggestions by the community - for example pdf previews.

## Role Centres

Multiple new role centres for an Ops Manager and Sales Admin, as well as changes to the Business Manager to make them more useful. Honestly role centres are completely crap!
I can't think of any competitor product that does this worse and most do it a lot better - yes even SAP with their new Web Client. 

The code is organised around entity areas.

## Banking

Improve on the basic list of bank accounts shown on the role centre  page by giving awareness of amount to be reconciled, date of last reconciliation, etc. Mainly inspired by how
Netsuite handles their bank account list.

## Brokerage

As a business we do a lot of brokerage containers. Whilst I'd love to adapt the standard sales quote , sales order functionality - it becomes fairly complex when we are essentially charging
for a service performed for our overseas supplier, but also want to treat our customer as a customer. There may be better ways of implementing this, but it gives us significant
advantages in what is a small, but profitable part of our business.

## Relationship Mgmt

The standard contact, opportunity, to-do and interaction management is a complete mess. We didn't want to create a completely separate system and so have cleaned-up, added and improved where
we can with low hanging fruit. That includes extending sales to more sales and purchase transactions, cleaning up the screens and making data readily available. It's not 
hubspot or salesforce - but as everyone knows there are advantages to data all in one place.

## Container Mgmt

Business Cental is a  mess when it comes to handling the concept of container shipments. It's not the data around the shipment, but the fact that it requires a purchase order to
be received into overseas location (in or to handle accounting and bill based on bill of lading date). As our requirement was not for combining multiple POs int a single container, 
the available solutions were a heavy hammer and we rolled our own.  Honestly it's still a cludge - but at least we have a way to tie together purchase order, purchase receipt, transfers 
(if we want them) and can add signficant intelligence around date management.

## Product Costings and Pricing Management

Possibly the heart of our business (and requiring a complete re-write if we activate the new pricing functionality). This allows us to use complex scenarios to calculate both
landed cost and selling prices (that are freight inclusive) and handle very complex logic such as drop ship purchase pricing that varies by customer destination and shifting exchange rates.
It also provides added sales price intelligence.

## Customer Management

Additional fields to manage customers, advanced order updates to customers giving them intelligent summaries and also improved approaches to handling quality management requirements.

## Item and Quality Management

Extensive additinal capabilities in lot tracking, quality management (CoA and Organic) and much improved awareness around how reservation management data is shown. We found the standard
solution to be almost unusable in terms of reservation management - leaving the user completely helpless about what the data means. We have added signficant intelligence and
easier navigation. We have also added concepts of vendor pricing units based on weight and a standardised price per kilogram pricing for items.

## Line List Pages

With the lack of ability to index non-database fields we needed pages that showed line items directly to allow us to search for an item and then work back from there. These pages are 
easily accessible from new factboxes on key role centres, cue groups on vendors, customers, etc.

## Common Management Functionality

Functionality that extends how pricing units work, standard report selection options (for our own report areas where we want flexibility on runtime report choice) and extending
setup pages. We chose to extend the relevant setup pages rather than create one completely our own - especially when new fields fitted with existing topics.

## Accounts Payable & Payment Functionality

We have signficantly enhanced payment journals to that a factbox actually tells you what vendor entries are being applied and gives you the ability to view and link to the underlying
transaction. Incredibly useful when combined with 'suggested payments'.  Yes we copied public domain blogs to show PDF Previews on incoming documents and its 'friggin' awesome 
and changes the game. It's embarrassing that it hasn't been done by the core team.

## Blanket POs

Made these actually useful by adding not just how much has been received, but how much is on order. Also added standard functionality you would see in any decent system like
start and end dates and also the ability to specify as a drop ship blanket agreement. Thereby managing back-to-back agreements with customers.

## Item Charges

Item charges are drastically overhauled to make it supereasy for us to apply sales freight charges from our freight company as well as landed costs. We can either add a reference at
head level in a purchase invoice or at line level within the description. It looks for certain patterns and autmatically looks up the correct sales shipment or purchase receipt and
applies it correctly. There are edge cases where it doesn't work - but it is an absolutely massive time saver - it also automatically populates descriptions. 

We have also done things like intelligently check for duplicate charges and allow you to very quickly drill between sales charges. Honestly Item Charges are awesome, but Microsoft
is not using them properly making it very difficulty to navigate and understand the data. We go a bit of the way in improving that.

## Quality

We throw in Vendor Certifications and Auditors for those companies who want to manage a log with expiry days. Sure we could implement in PowerApps - but that looked difficult and this
way we have 1-click navigation from anywhere as well as the ability to email directly from customers based on their purchase histry.

## Sales Shipments

Lots of minor improvements - including ability to track both 3PL reference and a freight tracking number. Yes many companies have 2. But also clean-up of lots of fields and helping
improve quality.

## Vendors

Lots of field cleanup - but also doing basic things like showing effective exchange rates on vendor ledger entries, allowing categories of vendors (should be there to start with) and
making external reference numbers more useful. 







