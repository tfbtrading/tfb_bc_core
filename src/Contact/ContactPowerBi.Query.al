query 50102 "TFB Contact PowerBI"
{
    QueryType = API;
    EntitySetName = 'tfbPowerBIContacts';
    EntityName = 'tfbPowerBIContact';
    APIPublisher = 'tfb';
    APIGroup = 'tfbPowerBI';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(contact; Contact)
        {
            column(typeOfContact; Type)
            {
            }
            column(address; Address)
            {
            }
            column(address2; "Address 2")
            {
            }
            column(city; City)
            {
            }
            column(companyName; "Company Name")
            {
            }
            column(companyNo; "Company No.")
            {
            }
            column(countryRegionCode; "Country/Region Code")
            {
            }
            column(county; County)
            {
            }
            column(eMail; "E-Mail")
            {
            }
            column(eMail2; "E-Mail 2")
            {
            }
            column(homePage; "Home Page")
            {
            }
            column(jobTitle; "Job Title")
            {
            }
            column(image; Image)
            {
            }

            column(firstName; "First Name")
            {
            }
            column(postCode; "Post Code")
            {
            }
            column(phoneNo; "Phone No.")
            {
            }
            column(surname; Surname)
            {
            }
            column(systemModifiedAt; SystemModifiedAt)
            {
            }
            column(buyingReason; "TFB Buying Reason")
            {
            }
            column(buyingTimeframe; "TFB Buying Timeframe")
            {
            }
            column(contactStage; "TFB Contact Stage")
            {
            }
            column(linkedinPage; "TFB Linkedin Page")
            {
            }
            column(leadSource; "TFB Lead Source")
            {
            }
            column(isCustomer; "TFB Is Customer")
            {
            }
            column(contactStatus; "TFB Contact Status")
            {
            }
            column(salesReadiness; "TFB Sales Readiness")
            {
            }
            column(territoryCode; "Territory Code")
            {
            }


        }
    }

}