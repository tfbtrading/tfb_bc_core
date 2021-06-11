report 50101 "TFB Sample Request"
{
    ApplicationArea = All;
    Caption = 'Sample Request';
    UsageCategory = Documents;
    WordLayout = 'Layouts/SampleRequest.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(TFBSampleRequest; "TFB Sample Request")
        {
            column(Address; Address)
            {
            }
            column(Address2; "Address 2")
            {
            }
            column(CampaignNo; "Campaign No.")
            {
            }
            column(City; City)
            {
            }
            column(Closed; Closed)
            {
            }
            column(CountryRegionCode; "Country/Region Code")
            {
            }
            column(County; County)
            {
            }
            column(LinesExist; LinesExist)
            {
            }
            column(No; "No.")
            {
            }
            column(OpportunityNo; "Opportunity No.")
            {
            }
            column(OrderDate; "Order Date")
            {
            }
            column(PackageTrackingNo; "Package Tracking No.")
            {
            }
            column(PostCode; "Post Code")
            {
            }
            column(PostingNo; "Posting No.")
            {
            }
            column(PostingNoSeries; "Posting No. Series")
            {
            }
            column(RequestedDeliveryDate; "Requested Delivery Date")
            {
            }
            column(SalespersonCode; "Salesperson Code")
            {
            }
            column(SelltoContact; "Sell-to Contact")
            {
            }
            column(SelltoContactNo; "Sell-to Contact No.")
            {
            }
            column(SelltoCustomerName; "Sell-to Customer Name")
            {
            }
            column(SelltoCustomerName2; "Sell-to Customer Name 2")
            {
            }
            column(SelltoCustomerNo; "Sell-to Customer No.")
            {
            }
            column(ShippingAgentCode; "Shipping Agent Code")
            {
            }
            column(SystemModifiedBy; SystemModifiedBy)
            {
            }
            column(WorkDescription; "Work Description")
            {
            }

            dataitem("TFB Sample Request Line"; "TFB Sample Request Line")
            {
                column(Line_Status; "Line Status")
                {

                }
                column(Location; Location)
                {

                }
                column(No_; "No.")
                {

                }
                column(Description; Description)
                {

                }
                column(Customer_Sample_Size; "Customer Sample Size")
                {

                }
                column(Source_Sample_Size; "Source Sample Size")
                {

                }
                column(Sourced_From; "Sourced From")
                {

                }
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
