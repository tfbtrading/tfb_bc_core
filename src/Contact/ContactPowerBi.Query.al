query 50102 "TFB Contact PowerBI"
{
    QueryType = API;
    EntitySetName = 'TFBPowerBIContacts';
    EntityName = 'TFBPowerBIContact';
    APIPublisher = 'TFB';
    APIGroup = 'PowerBI';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Contact; Contact)
        {
            column(Address; Address)
            {
            }
            column(Address2; "Address 2")
            {
            }
            column(City; City)
            {
            }
            column(CompanyName; "Company Name")
            {
            }
            column(CompanyNo; "Company No.")
            {
            }
            column(CountryRegionCode; "Country/Region Code")
            {
            }
            column(County; County)
            {
            }
            column(EMail; "E-Mail")
            {
            }
            column(EMail2; "E-Mail 2")
            {
            }
            column(HomePage; "Home Page")
            {
            }
            column(JobTitle; "Job Title")
            {
            }
            column(Image; Image)
            {
            }
            column(LastDateModified; "Last Date Modified")
            {
            }
            column(FirstName; "First Name")
            {
            }
            column(PostCode; "Post Code")
            {
            }
            column(PhoneNo; "Phone No.")
            {
            }
            column(Surname; Surname)
            {
            }
            column(SystemModifiedAt; SystemModifiedAt)
            {
            }
            column(TFBBuyingReason; "TFB Buying Reason")
            {
            }
            column(TFBBuyingTimeframe; "TFB Buying Timeframe")
            {
            }
            column(TFBContactStage; "TFB Contact Stage")
            {
            }
            column(TFBLinkedinPage; "TFB Linkedin Page")
            {
            }
            column(TFBLeadSource; "TFB Lead Source")
            {
            }
            column(TFBIsCustomer; "TFB Is Customer")
            {
            }
            column(TFBContactStatus; "TFB Contact Status")
            {
            }
            column(TFBSalesReadiness; "TFB Sales Readiness")
            {
            }
            column(TerritoryCode; "Territory Code")
            {
            }
            column(Type; Type)
            {
            }

        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}