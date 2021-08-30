query 50110 "TFB Container Payment Sched."
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;
    QueryCategory = 'Purchase Orders';

    elements
    {

        dataitem(Purchase_Header; "Purchase Header")
        {


            DataItemTableFilter = "Document Type" = const(Order);
            column(No_; "No.")
            {

            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Buy_from_Vendor_No_; "Buy-from Vendor No.")
            {

            }
            column(Amount; Amount)
            {

            }
            column(Currency_Code; "Currency Code")
            {

            }
            column(Requested_Receipt_Date; "Requested Receipt Date")
            {

            }



            dataitem(TFB_Container_Entry; "TFB Container Entry")
            {
                DataItemLink = "Order Reference" = Purchase_Header."No.";
                SqlJoinType = LeftOuterJoin;

                column(ContainerNo_; "No.")
                {

                }
                column(Container_No_; "Container No.")
                {

                }
                column(Est__Departure_Date; "Est. Departure Date")
                {

                }
                column(Departure_Date; "Departure Date")
                {

                }
                column(Status; Status)
                {

                }
            }
        }
    }



    trigger OnBeforeOpen()
    begin

    end;
}