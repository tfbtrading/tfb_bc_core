page 50127 "TFB Reservation Strategy"
{
    PageType = Card;
    SourceTable = "TFB Reservation Strategy";
    Editable = true;
    Caption = 'Reservation Strategy';
    DataCaptionFields = Code, Name;
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            field(Code; Rec.Code)
            {
                ToolTip = 'Specifies the value of the Code field';
            }
            field(Name; Rec.Name)
            {
                ToolTip = 'Specifies the value of the Name field';
            }
            group(InventoryOptions)
            {
                Caption = 'Inventory Option and Allocation Period';
                InstructionalText = 'Inventory that is currently on-hand is always considered for allocation. Optionally choose to also consider future inventory for allocation, which includes on-order and in-transit inventory that is not yet received.';

                field("Future Inventory"; Rec."Future Inventory")
                {
                    ToolTip = 'Specifies the value of the Future Inventory field';
                }
                group(AllocationPeriod)
                {
                    Caption = 'Allocation Period';
                    InstructionalText = 'Limit allocation of inventory to a determinate period before or after the supply required by date. Without an allocation period, the strategy takes into account all inventory that is available to allocate.';

                    group(Before)
                    {
                        Caption = 'Current and Future Inventory';
                        field("Limit Res. Period Before"; Rec."Limit Res. Period Before")
                        {
                            Caption = 'Limit Before';
                            ToolTip = 'Limit Inventory Allocation Period Before Requested Shipment Date';
                        }
                        field("Limit Before Days"; Rec."Limit Before Days")
                        {
                            Width = 4;
                            ToolTip = 'Specifies the value of the Limit Before Days field';
                        }
                    }
                    group(After)
                    {
                        Caption = 'Future Inventory Only';
                        ShowCaption = true;
                        field("Limit Res. Period After"; Rec."Limit Res. Period After")
                        {
                            Caption = 'Limit Inventory Allocation Period After Requested Shipment Date';
                            ToolTip = 'Specifies the value of the Limit Inventory Allocation Period After Requested Shipment Date field';
                        }
                        field("Limit After Days"; Rec."Limit After Days")
                        {
                            Width = 4;
                            ToolTip = 'Specifies the value of the Limit After Days field';

                        }
                    }


                }
            }
            group(ÄllocationRules)
            {
                Caption = 'Allocation Rules';

                field("Reservation Method"; Rec."Reservation Method")
                {
                    ToolTip = 'Specifies the value of the Reservation Method field';
                }
                field("Reservation Quantity"; Rec."Reservation Quantity")
                {
                    ToolTip = 'Specifies the value of the Reservation Quantity field';
                }
                field("Reservation Type"; Rec."Reservation Type")
                {
                    ToolTip = 'Specifies the value of the Reservation Type field';
                }
            }
            field("No. of Customers"; Rec."No. of Customers")
            {
                Caption = 'No. Of Customers Using Strategy';
                ToolTip = 'Specifies the value of the No. Of Customers Using Strategy field';
            }
            field(SystemModifiedAt; Rec.SystemModifiedAt)
            {
                ToolTip = 'Specifies the value of the SystemModifiedAt field';
            }



        }
    }


    actions
    {
        area(Processing)
        {

        }
    }


}