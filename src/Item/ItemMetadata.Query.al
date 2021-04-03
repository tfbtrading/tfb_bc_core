query 50104 "TFB Item Metadata"
{
    QueryType = Normal;
    Caption = 'Item Metadata Query';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Item; Item)
        {
            column(No_; "No.")
            {

            }
            column(Description; Description)
            {

            }
            column(TFB_Alt__Names; "TFB Alt. Names")
            {

            }
            column(Net_Weight; "Net Weight")
            {

            }
            column(Vendor_No_; "Vendor No.")
            {

            }
            column(Base_Unit_of_Measure; "Base Unit of Measure")
            {

            }
            column(Sales_Unit_of_Measure; "Sales Unit of Measure")
            {

            }
            column(Blocked; Blocked)
            {

            }
            column(Country_Region_of_Origin_Code; "Country/Region of Origin Code")
            {

            }
            column(Country_Region_Purchased_Code; "Country/Region Purchased Code")
            {

            }
            column(Item_Category_Id; "Item Category Id")
            {

            }
            column(Minimum_Order_Quantity; "Minimum Order Quantity")
            {

            }
            column(Maximum_Order_Quantity; "Maximum Order Quantity")
            {

            }
            column(Safety_Stock_Quantity; "Safety Stock Quantity")
            {

            }
            column(SystemModifiedAt; SystemModifiedAt)
            {

            }
            column(SystemCreatedAt; SystemCreatedAt)
            {

            }
            column(TFB_Publishing_Block; "TFB Publishing Block")
            {

            }

        }


    }



    trigger OnBeforeOpen()
    begin

    end;
}