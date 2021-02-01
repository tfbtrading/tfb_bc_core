page 50301 "TFB Costing Scenario"
{
    PageType = Card;

    UsageCategory = None;
    SourceTable = "TFB Costing Scenario";
    Caption = 'Costing Scenario';
    layout
    {
        area(Content)
        {
            group("General")
            {
                group("Summary")
                {
                    field("Code"; Rec."Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies unique code for costing scenario';
                    }
                    field("Effective Date"; Rec."Effective Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies initial effective date';
                    }

                }
                group("Finance")
                {
                    field("Exchange Rate"; Rec."Exchange Rate")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies default exchange rate';
                    }
                    field("Finance Rate"; Rec."Finance Rate")
                    {
                        ApplicationArea = All;
                        Caption = 'Finance Rate %';
                        ToolTip = 'Specifies the financing rate for import finance';
                    }
                    field("Bank Charge"; Rec."Bank Charge")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies standard bank charge for import finance';
                    }
                    field("Finance Duration"; Rec."Finance Duration")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies days duration for import finance';
                    }
                    field("Def. Storage Duration"; Rec."Def. Storage Duration")
                    {
                        ApplicationArea = All;
                        Caption = 'Default Storage Duration';
                        ToolTip = 'Specifies days goods are likely to be stored on average';
                    }
                    field("Fuel Surcharge %"; Rec."Fuel Surcharge %")
                    {

                        ApplicationArea = All;
                        ToolTip = 'Specifies fuel surcharge rate for transport carriers';
                    }
                }
            }
            group("Logistics")
            {
                Caption = 'Logistics costs';
                group("Per Pallet")
                {
                    group("Inbound")
                    {

                        field("Inspection Charge"; Rec."Inspection Charge")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies inspection charge for handing AQIS inspection at warehouse';
                        }
                        field("Pallet Package Bundle"; Rec."Pallet Package Bundle")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies price of bundle for container palletisation and pallet movement';
                        }
                        field("Shrink Wrapping"; Rec."Shrink Wrapping")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies cost  to shrink wrap pallet';
                        }
                        field("Storage Charge"; Rec."Storage")
                        {
                            ApplicationArea = All;
                            Caption = 'Storage Charge Per Week';
                            ToolTip = 'Specifies storage charge per week per pallet';
                        }

                        field("Label Fee"; Rec."Labelling")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies labelling fees for pallet at 3pl warehouse';
                        }
                        field("Pallet Putaway Charge"; Rec."Pallet Putaway Charge")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies pallet putaway costs';
                        }
                        field("Pallet In Charge"; Rec."Pallet In Charge")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies pallet charge for handling inbound pallet from container/vehicle into warehouse';
                        }


                    }
                    group("Outbound")
                    {
                        field("Order Handling"; Rec."Order Handling")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Includes any fixed order and consignment charges';

                        }
                        field("Pallet Out Charge"; Rec."Pallet Out Charge")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Includes charges for picking and dispatching pallet. Assumes full pallets';
                        }
                    }
                }
                group("Per Container")
                {


                    field("Port Cartage"; Rec."Port Cartage")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies cost to move goods from port to warehouse';
                    }
                    field("Unpack Loose"; Rec."Unpack Loose")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies cost unpack goods from container/semiload';
                    }
                    field("Unpack Standard"; Rec."Unpack Standard")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies cost to unpack standard container size';
                    }
                    field("Customs Declaration"; Rec."Customs Declaration")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies cost of customs declaration';
                    }
                    field("Fumigation"; Rec."Fumigation")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies cost to undertake fumigation of goods';
                    }
                    field("Heat Treatment"; Rec."Heat Treatment")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies cost to undertake heat treatment of goods';
                    }
                    field("Container Contingency"; Rec."Container Contingency")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies potential unknown costs incurred by bringing in container. i.e. Logistics/AQIS/Testing';
                    }
                }
            }
            group("Pricing Defaults")
            {

                field("Pricing Margin %"; Rec."Pricing Margin %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies pricing margin % standard to default on item costings';
                }
                field("Market Price Margin %"; Rec."Market Price Margin %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies market price marging % standard to default on item costings';
                }
                field("Full Load Margin %"; Rec."Full Load Margin %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies discount on brining in a full container load';
                }

            }

            part("Postal Zone Costs"; "TFB Costing Scenario SubForm")
            {



                ApplicationArea = All;
                SubPageLink = "Costing Scenario Code" = field(Code);
                UpdatePropagation = SubPart;
                Visible = true;


            }

        }
    }
}
