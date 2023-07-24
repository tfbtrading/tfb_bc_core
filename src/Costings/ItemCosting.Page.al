/// <summary>
/// Page TFB Item Costing (ID 50348).
/// </summary>
page 50348 "TFB Item Costing"
{
    PageType = Card;
    SourceTable = "TFB Item Costing Revised";
    DelayedInsert = true;
    Caption = 'Item Costing';
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            group("General")
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies item number being costed';
                }

                field("Description"; Rec."Description")
                {
                    Tooltip = 'Specifies description of item being costed';
                }
                field("Item Category"; Rec."Item Category")
                {
                    Tooltip = 'Specifies item category of item being costed';
                }
                field("Costing Type"; Rec."Costing Type")
                {
                    Tooltip = 'Specifies type of costing - is it for specific customer or general';
                }
                group(CustomerDetails)
                {
                    Visible = Rec."Costing Type" = Rec."Costing Type"::Customer;
                    ShowCaption = false;
                    field("Customer No."; Rec."Customer No.")
                    {
                        ToolTip = 'Specifies initial effective date on which costing is created';
                    }
                    field("Customer Name"; Rec."Customer Name")
                    {
                        Editable = true;
                        Tooltip = 'Specifies whether item costing is current and effective';

                    }
                }
                field(HasLines; Rec.HasLines)
                {
                    Caption = 'Valid - Lines Generated';
                    Editable = false;
                    ToolTip = 'Specifies if lines have been calculated';

                }

                field("Landed Cost Profile"; Rec."Landed Cost Profile")
                {
                    ToolTip = 'Specifies landed cost profile used to generate item costing';


                }

                field("Scenario Override"; Rec."Scenario Override")
                {
                    Tooltip = 'Specifies if scenario used in landed cost profile is overriden on item costing';
                }
                field("Vendor No.";
                Rec."Vendor No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies vendor for used for calculating item costing';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Importance = Standard;
                    ToolTip = 'Specifies name of vendor';
                }
                field("Fix Exch. Rate"; Rec."Fix Exch. Rate")
                {
                    Importance = Standard;
                    ToolTip = 'Ensures that the exchange rate is not updated when the related scenario exchange rate changes or during automated processes';
                }
            }

            group("Costing Detail")
            {
                group("Pricing")
                {
                    Caption = 'Pricing and Margin';
                    field("Purchase Price Unit"; Rec."Purchase Price Unit")
                    {
                        ToolTip = 'Specifies purchase price unit in which prices are expressed';
                    }
                    field("Est. Current Cost"; Rec."Average Cost")
                    {
                        ToolTip = 'Specifies current average cost for item being costed';
                    }

                    field("Market Cost"; Rec."Market Price")
                    {
                        Tooltip = 'Specifies latest replacement or market cost for item';
                    }

                    field("Pricing Margin %"; Rec."Pricing Margin %")
                    {
                        ToolTip = 'Specifies pricing margin based on current average cost';
                    }
                    field("Market Cost Margin %"; Rec."Market Price Margin %")
                    {
                        Tooltip = 'Specifies pricing market for projected market cost. Based on prevailing market margins projected.';

                    }
                    field("Full Load Margin %"; Rec."Full Load Margin %")
                    {
                        Tooltip = 'Specifies discount on full pallet load';
                    }

                }
                group("Drivers")
                {
                    field("Pallet Qty"; Rec."Pallet Qty")
                    {
                        ToolTip = 'Specifies pallet qty for item costing';


                    }

                    field("Vendor Currency"; Rec."Vendor Currency")
                    {
                        ToolTip = 'Specifies currency used for goods purchased';


                    }
                    group(ForeignCurrency)
                    {
                        ShowCaption = false;
                        Visible = Rec."Vendor Currency" <> '';

                        field("Exch. Rate"; Rec."Exch. Rate")
                        {
                            enabled = Rec."Vendor Currency" <> '';
                            ToolTip = 'Specifies exch. rate. used to calculate when foreign currency is used';
                        }
                    }
                    field("Days Financed"; Rec."Days Financed")
                    {
                        ToolTip = 'Specifies number of days financed';
                    }
                    field("Dropship"; Rec."Dropship")
                    {
                        ToolTip = 'Specifies if load is drop shipped directly to customer';
                    }
                    group(dropShipItems)
                    {
                        ShowCaption = false;
                        Visible = not Rec.Dropship;
                        field("Est. Item Storage"; Rec."Est. Storage Duration")
                        {
                            BlankZero = false;
                            ToolTip = 'Specifies item duration for storage in days';
                        }
                    }



                }

            }

            part("Lines"; "TFB Item Costing Subform")
            {
                SubPageLink = "Item No." = field("Item No."), "Costing Type" = field("Costing Type"), "Customer No." = field("Customer No.");
                UpdatePropagation = SubPart;
                Visible = true;
                Caption = 'Lines';

            }
        }
        area(Factboxes)
        {
            part(ItemDet; "Item Picture")
            {
                SubPageLink = "No." = field("Item No.");

            }

            part(ItemPlan; "TFB Item Costing Factbox")
            {
                SubPageLink = "No." = field("Item No.");

            }


        }


    }






    actions
    {
        area(Navigation)
        {
            action("Cost Scenario")
            {
                image = Cost;
                RunObject = Page "TFB Landed Cost Profile";
                RunPageLink = Code = field("Landed Cost Profile");
                RunPageMode = View;
                ToolTip = 'Open landed cost profile';



            }
            action("Item ")
            {
                image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = field("Item No.");
                RunPageMode = View;
                Tooltip = 'Open item';

            }
            action("Vendor")
            {
                image = Vendor;
                RunObject = Page "Vendor Card";
                RunPageLink = "No." = field("Vendor No.");
                RunPageMode = View;
                Tooltip = 'Open vendor';

            }


        }

        area(Processing)
        {

            action("Refresh")
            {
                image = RefreshLines;
                ToolTip = 'Refresh all costing lines';

                trigger OnAction()
                begin
                    rec.CalcCostings(Rec);
                    CurrPage.Lines.Page.Update();

                end;
            }
        }

        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';


                actionref(RefreshRef; Refresh)
                {

                }


            }
            group(Category_ItemCosting)
            {
                Caption = 'Item Costing';
                actionref(ItemRef; "Item ")
                {

                }
                actionref(CostScenarioRef; "Cost Scenario")
                {

                }
            }
        }
    }



}