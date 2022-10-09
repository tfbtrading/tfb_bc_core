page 50173 "TFB Core Setup"
{

    PageType = Card;
    SourceTable = "TFB Core Setup";
    Caption = 'TFB Core Extension Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(NumberSeries)
            {
                field("Brokerage Shipment Nos."; Rec."Brokerage Shipment Nos.")
                {
                    ToolTip = 'Specifies the value of the Brokerage Shipment Nos. field.';
                }
                field("Container Entry Nos."; Rec."Container Entry Nos.")
                {
                    ToolTip = 'Specifies the value of the Cont. Entry No. field.';
                }
                field("Sample Request Nos."; Rec."Sample Request Nos.")
                {
                    ToolTip = 'Specifies the value of the Sample Request Nos. field.';
                }
                field("Posted Sample Request Nos."; Rec."Posted Sample Request Nos.")
                {
                    ToolTip = 'Specifies the value of the Pstd. Sample Request Nos. field.';
                }

            }
            group(AzureStorageConfig)
            {
                Caption = 'Azure Storage Config';
                group("Lot Samples")
                {
                    field("ABS Lot Sample Access Key"; Rec."ABS Lot Sample Access Key")
                    {
                        ToolTip = 'Specifies the value of the ABS Shared Access Key for Lot Samples field.';
                    }
                    field("ABS Lot Sample Account"; Rec."ABS Lot Sample Account")
                    {
                        ToolTip = 'Specifies the value of the ABS Account Name for Lot Samples field.';
                    }
                    field("ABS Lot Sample Container"; Rec."ABS Lot Sample Container")
                    {
                        ToolTip = 'Specifies the value of the ABS Container Name for Lot Samples field.';
                    }
                }
                group("Proof of Deliveries")
                {
                    field("ABS POD Access Key"; Rec."ABS POD Access Key")
                    {
                        ToolTip = 'Specifies the value of the ABS Shared Access Key field.';
                    }
                    field("ABS POD Account"; Rec."ABS POD Account")
                    {
                        ToolTip = 'Specifies the value of the ABS Account Name field.';
                    }
                    field("ABS POD Container"; Rec."ABS POD Container")
                    {
                        ToolTip = 'Specifies the value of the ABS Container Name field.';
                    }
                }
            }
            group(SalesReceivables)
            {
                field("ASN Def. Job Resp. Rec."; Rec."ASN Def. Job Resp. Rec.")
                {
                    ToolTip = 'Specifies the value of the Shipment Notification Job Resp. field.';
                }
                field("Auto Shipment Notification"; Rec."Auto Shipment Notification")
                {
                    ToolTip = 'Specifies the value of the Notify Customer on Shipment field.';
                }
                field("Brokerage Contract Nos."; Rec."Brokerage Contract Nos.")
                {
                    ToolTip = 'Specifies the value of the Brokerage Contract Nos. field.';
                }
                field("Brokerage Cust. Update"; Rec."Brokerage Cust. Update")
                {
                    ToolTip = 'Specifies the value of the Brokerage Cust. Updates field.';
                }
                field("Brokerage Default %"; Rec."Brokerage Default %")
                {
                    ToolTip = 'Specifies the value of the Brokerage Default % field.';
                }
                field("Brokerage Service Item"; Rec."Brokerage Service Item")
                {
                    ToolTip = 'Specifies the value of the Brokerage Service Item field.';
                }
              
                field("Converted Status"; Rec."Converted Status")
                {
                    ToolTip = 'Specifies the value of the Customer/Vendor Status Default field.';
                }
                field("Credit Tolerance"; Rec."Credit Tolerance")
                {
                    ToolTip = 'Specifies the value of the Credit Tolerance field.';
                }
                field("Def. Customer Price Group"; Rec."Def. Customer Price Group")
                {
                    ToolTip = 'Specifies the value of the Def. Cust. Price Group field.';
                }
                field("Email Template Active"; Rec."Email Template Active")
                {
                    ToolTip = 'Specifies the value of the Email Template Active URL field.';
                }
                field("Email Template Test"; Rec."Email Template Test")
                {
                    ToolTip = 'Specifies the value of the Email Template Test URL field.';
                }
                field("Image URL Pattern"; Rec."Image URL Pattern")
                {
                    ToolTip = 'Specifies the value of the Item Image URL Pattern field.';
                }
                field("Lead Status"; Rec."Lead Status")
                {
                    ToolTip = 'Specifies the value of the Lead Status Default field.';
                }

                field("PL Def. Job Resp. Rec."; Rec."PL Def. Job Resp. Rec.")
                {
                    ToolTip = 'Specifies the value of the Price List Job Resp. field.';
                }
                field("Prospect Status - New"; Rec."Prospect Status - New")
                {
                    ToolTip = 'Specifies the value of the Prospect (New) Status Default field.';
                }
                field("Prospect Status - Opp"; Rec."Prospect Status - Opp")
                {
                    ToolTip = 'Specifies the value of the Prospect (Opportunity) Status Default field.';
                }
                field("Prospect Status - Quote"; Rec."Prospect Status - Quote")
                {
                    ToolTip = 'Specifies the value of the Prospect (Quote) Status Default field.';
                }
            }


            group(ItemSetup)
            {
                field("Certificate of Analysis"; Rec."Certificate of Analysis")
                {
                    ToolTip = 'Specifies the value of the Certificate of Analysis field.';
                }
                field("Item Price Group"; Rec."Item Price Group")
                {
                    ToolTip = 'Specifies the value of the Item Unit Price Group field.';
                }
                field("MSDS Word Template"; Rec."MSDS Word Template")
                {
                    ToolTip = 'Specifies the value of the MSDS Word Template field.';
                }
                field("Show External IDs"; Rec."Show External IDs")
                {
                    ToolTip = 'Specifies the value of the Show External Ids field.';
                }
                field("Specification URL Pattern"; Rec."Specification URL Pattern")
                {
                    ToolTip = 'Specifies the value of the Specification URL Pattern field.';
                }
                field("QDS Def. Job Resp."; Rec."QDS Def. Job Resp.")
                {
                    ToolTip = 'Specifies the value of the Quality Docs Subs. Job Resp. field.';
                }
                field("Shipment Status Enquiry"; Rec."Shipment Status Enquiry")
                {
                    ToolTip = 'Specifies the value of the Shipment Status Enquiries field.';
                }

            }

            Group(Costings)
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


    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;

}
