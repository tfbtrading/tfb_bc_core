query 50109 "TFB Item Generic Info"
{
    QueryType = Normal;
    Caption = 'Item Generic Information';
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
            column(Block_Reason; "Block Reason")
            {

            }
            column(TFB_Publishing_Block; "TFB Publishing Block")
            {

            }
            column(Item_Category_Code; "Item Category Code")
            {

            }

            dataitem(TFB_Generic_Item; "TFB Generic Item")
            {
                DataItemLink = SystemId = Item."TFB Generic Item ID";
                SqlJoinType = LeftOuterJoin;
                column(GenericDescription; Description)
                {

                }
                column(GenericExternalID; "External ID")
                {

                }
                column(GenericCategoryCode; "Item Category Code")
                {

                }

            }



        }

    }


    trigger OnBeforeOpen()
    begin

    end;
}