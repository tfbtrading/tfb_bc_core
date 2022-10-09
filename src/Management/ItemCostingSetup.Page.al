page 50332 "TFB Item Costing Setup"
{

    PageType = Card;
    SourceTable = "TFB Costings Setup";
    Caption = 'Item Costing Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Tasks;
    ApplicationArea = All;
    ObsoleteReason = 'Consolidated into single table';
    ObsoleteState = Pending;
    ObsoleteTag = '21';


    layout
    {
        area(content)
        {
            GROUP(General)
            {

                field("Default Postal Zone"; Rec."Default Postal Zone")
                {
                    ApplicationArea = All;
                    Tooltip = 'Selects postal zone treated as default';
                }
                field(ExWarehouseEnabled; Rec.ExWarehouseEnabled)
                {
                    ApplicationArea = All;
                    Caption = 'Ex Warehouse Enabled';
                    ToolTip = 'Set to true to generate sale price worksheet entries for ex-warehouse pricing';
                }
                field(ExWarehousePricingGroup; Rec.ExWarehousePricingGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Ex Warehouse Pricing Group';
                    ToolTip = 'Ex warehouse customer pricing group';
                }
                field("mport Duty Rate"; Rec."Import Duty Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Used to add import duties to landed cost if the switch is setup in profile';
                }

            }

            group("Charges")

            {
                Caption = 'Item Charge Allocations';


                field("Port Cartage Item Charge"; Rec."Port Cartage Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }
                field("Cust. Decl. Item Charge"; Rec."Cust. Decl. Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }
                field("Ocean Freight Item Charge"; Rec."Ocean Freight Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }
                field("Unpack Item Charge"; Rec."Unpack Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }
                field("Port Documents"; Rec."Port Documents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }
                field("Fumigation Fees Item Charge"; Rec."Fumigation Fees Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }
                field("Quarantine Fees Item Charge"; Rec."Quarantine Fees Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code to use when generating templates.';
                }


            }


        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;

}
