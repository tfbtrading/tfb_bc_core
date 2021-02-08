query 50107 "TFB Transfer Lines Outstanding"
{
    QueryType = Normal;
    Caption = 'Transfer Lines Outstanding';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Transfer_Line; "Transfer Line")
        {


            column(Document_No_; "Document No.")
            {

            }
            column(Line_No_; "Line No.")
            {

            }
            column(Transfer_from_Code; "Transfer-from Code")
            {

            }

            column(Transfer_to_Code; "Transfer-to Code")
            {

            }
            column(Item_No_; "Item No.")
            {

            }

            column(Quantity__Base_; "Quantity (Base)")
            {

            }



            column(Outstanding_Qty___Base_; "Outstanding Qty. (Base)")
            {

            }
            column(Unit_of_Measure; "Unit of Measure")
            {

            }
            column(Receipt_Date; "Receipt Date")
            {

            }


        }
    }
}