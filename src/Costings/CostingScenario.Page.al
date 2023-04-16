page 50301 "TFB Costing Scenario"
{
    PageType = Card;

    UsageCategory = None;
    SourceTable = "TFB Costing Scenario";
    Caption = 'Costing Scenario';
    ApplicationArea = All;

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
                        Importance = Promoted;
                        ToolTip = 'Specifies unique code for costing scenario';
                    }
                    field("Effective Date"; Rec."Effective Date")
                    {
                        ToolTip = 'Specifies initial effective date';
                    }

                }
                group("Finance")
                {
                    field("Exchange Rate"; Rec."Exchange Rate")
                    {
                        ToolTip = 'Specifies default exchange rate';
                    }
                    field("Finance Rate"; Rec."Finance Rate")
                    {
                        Caption = 'Finance Rate %';
                        ToolTip = 'Specifies the financing rate for import finance';
                    }
                    field("Bank Charge"; Rec."Bank Charge")
                    {
                        ToolTip = 'Specifies standard bank charge for import finance';
                    }
                    field("Finance Duration"; Rec."Finance Duration")
                    {
                        ToolTip = 'Specifies days duration for import finance';
                    }
                    field("Def. Storage Duration"; Rec."Def. Storage Duration")
                    {
                        Caption = 'Default Storage Duration';
                        ToolTip = 'Specifies days goods are likely to be stored on average';
                    }
                    field("Fuel Surcharge %"; Rec."Fuel Surcharge %")
                    {
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
                            ToolTip = 'Specifies inspection charge for handing AQIS inspection at warehouse';
                        }
                        field("Pallet Package Bundle"; Rec."Pallet Package Bundle")
                        {
                            ToolTip = 'Specifies price of bundle for container palletisation and pallet movement';
                        }
                        field("Shrink Wrapping"; Rec."Shrink Wrapping")
                        {
                            ToolTip = 'Specifies cost  to shrink wrap pallet';
                        }
                        field("Storage Charge"; Rec."Storage")
                        {
                            Caption = 'Storage Charge Per Week';
                            ToolTip = 'Specifies storage charge per week per pallet';
                        }

                        field("Label Fee"; Rec."Labelling")
                        {
                            ToolTip = 'Specifies labelling fees for pallet at 3pl warehouse';
                        }
                        field("Pallet Putaway Charge"; Rec."Pallet Putaway Charge")
                        {
                            ToolTip = 'Specifies pallet putaway costs';
                        }
                        field("Pallet In Charge"; Rec."Pallet In Charge")
                        {
                            ToolTip = 'Specifies pallet charge for handling inbound pallet from container/vehicle into warehouse';
                        }


                    }
                    group("Outbound")
                    {
                        field("Order Handling"; Rec."Order Handling")
                        {
                            ToolTip = 'Includes any fixed order and consignment charges';

                        }
                        field("Pallet Out Charge"; Rec."Pallet Out Charge")
                        {
                            ToolTip = 'Includes charges for picking and dispatching pallet. Assumes full pallets';
                        }
                    }
                }
                group("Per Container")
                {


                    field("Port Cartage"; Rec."Port Cartage")
                    {
                        ToolTip = 'Specifies cost to move goods from port to warehouse';
                    }
                    field("Unpack Loose"; Rec."Unpack Loose")
                    {
                        ToolTip = 'Specifies cost unpack goods from container/semiload';
                    }
                    field("Unpack Standard"; Rec."Unpack Standard")
                    {
                        ToolTip = 'Specifies cost to unpack standard container size';
                    }
                    field("Customs Declaration"; Rec."Customs Declaration")
                    {
                        ToolTip = 'Specifies cost of customs declaration';
                    }
                    field("Fumigation"; Rec."Fumigation")
                    {
                        ToolTip = 'Specifies cost to undertake fumigation of goods';
                    }
                    field("Heat Treatment"; Rec."Heat Treatment")
                    {
                        ToolTip = 'Specifies cost to undertake heat treatment of goods';
                    }
                    field("Container Contingency"; Rec."Container Contingency")
                    {
                        ToolTip = 'Specifies potential unknown costs incurred by bringing in container. i.e. Logistics/AQIS/Testing';
                    }
                }
            }
            group("Pricing Defaults")
            {

                field("Pricing Margin %"; Rec."Pricing Margin %")
                {
                    ToolTip = 'Specifies pricing margin % standard to default on item costings';
                }
                field("Market Price Margin %"; Rec."Market Price Margin %")
                {
                    ToolTip = 'Specifies market price marging % standard to default on item costings';
                }
                field("Full Load Margin %"; Rec."Full Load Margin %")
                {
                    ToolTip = 'Specifies discount on brining in a full container load';
                }

            }

            part("Postal Zone Costs"; "TFB Costing Scenario SubForm")
            {
                SubPageLink = "Costing Scenario Code" = field(Code);
                UpdatePropagation = SubPart;
                Visible = true;


            }

        }
    }
}
