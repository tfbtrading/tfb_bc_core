page 50127 "TFB Reservation Strategy"
{
    PageType = Card;
    SourceTable = "TFB Reservation Strategy";
    Editable = true;
    Caption = 'Reservation Strategy';
    DataCaptionFields = Code, Name;

    layout
    {
        area(Content)
        {
            field(Code; Rec.Code)
            {
                ApplicationArea = All;
            }
            field(Name; Rec.Name)
            {
                ApplicationArea = All;
            }
            group(InventoryOptions)
            {
                Caption = 'Inventory Option and Allocation Period';
                InstructionalText = 'Inventory that is currently on-hand is always considered for allocation. Optionally choose to also consider future inventory for allocation, which includes on-order and in-transit inventory that is not yet received.';

                field("Future Inventory"; Rec."Future Inventory")
                {
                    ApplicationArea = All;
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
                            ApplicationArea = All;
                        }
                        field("Limit Before Days"; Rec."Limit Before Days")
                        {
                            ApplicationArea = All;
                            Width = 4;
                        }
                    }
                    group(After)
                    {
                        Caption = 'Future Inventory Only';
                        ShowCaption = true;
                        field("Limit Res. Period After"; Rec."Limit Res. Period After")
                        {
                            ApplicationArea = All;
                            Caption = 'Limit Inventory Allocation Period After Requested Shipment Date';
                        }
                        field("Limit After Days"; Rec."Limit After Days")
                        {
                            ApplicationArea = All;
                            Width = 4;

                        }
                    }


                }
            }
            group(ÄllocationRules)
            {
                Caption = 'Allocation Rules';

                field("Reservation Method"; Rec."Reservation Method")
                {
                    ApplicationArea = All;
                }
                field("Reservation Quantity"; Rec."Reservation Quantity")
                {
                    ApplicationArea = All;
                }
                field("Reservation Type"; Rec."Reservation Type")
                {
                    ApplicationArea = All;
                }
            }
            field("No. of Customers"; Rec."No. of Customers")
            {
                ApplicationArea = All;
                Caption = 'No. Of Customers Using Strategy';
            }
            field(SystemModifiedAt; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
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