query 50100 "TFB Items Shipped"
{
    QueryType = Normal;

    elements
    {
        dataitem(Sales_Shipment_Line; "Sales Shipment Line")
        {
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
            {


            }
            column(No_; "No.")
            {

            }

            dataitem(Item; Item)
            {
                DataItemLink = "No." = Sales_Shipment_Line."No.";
                SqlJoinType = LeftOuterJoin;

                column(Vendor_No_; "Vendor No.")
                {

                }
            }
            column(Count_)
            {
                Method = Count;
            }
            filter(Posting_Date; "Posting Date")
            {

            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}