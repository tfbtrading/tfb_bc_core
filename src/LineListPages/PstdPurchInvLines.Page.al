page 50104 "TFB Pstd. Purch. Inv. Lines"
{
    PageType = List;
    SourceTable = "Purch. Inv. Line";
    Caption = 'Pstd. Purch. Inv. Lines';
    SourceTableView = sorting("Buy-from Vendor No.", "Posting Date") order(descending) where(Type = filter(Item), Quantity = filter(> 0));

    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date invoice was posted';

                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = true;
                    Tooltip = 'Specifies document number of invoice';

                    trigger OnDrillDown()

                    var
                        Header: Record "Purch. Inv. Header";
                        Invoice: Page "Posted Purchase Invoice";

                    begin
                        Header.Get(Rec."Document No.");
                        Invoice.SetRecord(Header);
                        Invoice.Editable(true);
                        Invoice.Run();
                    end;

                }

                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Lookup = false;
                    DrillDown = true;
                    DrillDownPageId = "Vendor Card";
                    Tooltip = 'Specifies vendor for purchase invoice';

                }
                field(VendorName; Rec."TFB Vendor Name")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor';
                    DrillDown = true;
                    Tooltip = 'Specifies vendor name for purchase invoice';

                    Trigger OnDrillDown()

                    var
                        VendorRec: Record Vendor;
                        Vendor: Page "Vendor Card";

                    begin
                        VendorRec.Get(Rec."Pay-to Vendor No.");
                        Vendor.Editable(true);
                        Vendor.SetRecord(VendorRec);
                        Vendor.Run();
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    DrillDown = true;
                    DrillDownPageId = "Item Card";
                    Tooltip = 'Specifies item number';
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies description of item';
                }


                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies quantity invoiced';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies unit of measure for quantity invoices';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per UoM';
                    Tooltip = 'Specifies quantity per unit of measure for purchase unit';
                }
                field("Purchasing Code"; Rec."Purchasing Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies purchase code';
                }
                field("TFB Price Per Kg"; PricePerKg)
                {

                    ApplicationArea = All;
                    Tooltip = 'Specifies price per kg';
                    Caption = 'Per Kg Price';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    Lookup = true;
                    LookupPageId = "Purchase Order";
                    ApplicationArea = All;
                    Tooltip = 'Specifies direct unit cost of item invoiced';

                }





            }
        }
        area(Factboxes)
        {
            Part(Item; "Item Invoicing FactBox")
            {
                SubPageLink = "No." = field("No.");
                ApplicationArea = All;
            }

        }
    }


    actions
    {

        area(Navigation)
        {


            action(Receipt)
            {
                RunObject = Page "Posted Purchase Receipt";
                RunPageLink = "No." = field("Receipt No.");
                RunPageMode = View;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Receipt;
                ToolTip = 'Opens posted purchase receipt for invoice';
            }


        }
        area(Processing)
        {
        }
    }

    views
    {


    }

    var

        PricingCU: Codeunit "TFB Pricing Calculations";
        PricePerKg: Decimal;
        PricingUnit: Enum "TFB Price Unit";

    trigger OnAfterGetRecord()

    begin

        PricingUnit := PricingUnit::KG;
        If Rec.Type = Rec.Type::Item then
            PricePerKg := PricingCU.CalculatePriceUnitByUnitPrice(Rec."No.", Rec."Unit of Measure Code", PricingUnit, Rec."Direct Unit Cost")
        else
            PricePerKg := 0;

    end;

}