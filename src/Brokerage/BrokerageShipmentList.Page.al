page 50230 "TFB Brokerage Shipment List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Brokerage Shipment";
    SourceTableView = where(Closed = const(false));
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = true;
    CardPageId = "TFB Brokerage Shipment";
    Caption = 'Ongoing Brokerage Shipments';
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies no. of brokerage shipment';

                }
                field("Contract No."; Rec."Contract No.")
                {
                    TableRelation = "TFB Brokerage Contract";

                    DrillDown = true;
                    DrillDownPageId = "TFB Brokerage Contract";
                    Tooltip = 'Specifies contract no';
                }

                field("Customer Name"; Rec."Customer Name")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies customer name';

                    trigger OnDrillDown()

                    var
                        Customer: Record Customer;
                        CustomerPage: Page "Customer Card";


                    begin
                        if Customer.Get(Rec."Customer No.") then begin
                            CustomerPage.SetRecord(Customer);
                            CustomerPage.Run();
                        end;
                    end;


                }

                field("Vendor Name"; Rec."Buy From Vendor Name")
                {
                    Importance = Promoted;
                    Tooltip = 'Specifies vendor name';
                    trigger OnDrillDown()

                    var
                        Vendor: Record Vendor;
                        VendorPage: Page "Vendor Card";


                    begin
                        if Vendor.Get(Rec."Buy From Vendor No.") then begin
                            VendorPage.SetRecord(Vendor);
                            VendorPage.Run();
                        end;
                    end;
                }
                field("Customer Reference"; Rec."Customer Reference")
                {
                    Importance = Promoted;
                    Tooltip = 'Specifies customer reference';
                }
                field("Container No."; Rec."Container No.")
                {
                    Tooltip = 'Specifies container number';
                }
                field("Est. Arrival Date"; Rec."Est. Arrival Date")
                {
                    ToolTip = 'Specifies est. arrival date';
                }
                field("Required Arrival Date"; Rec."Required Arrival Date")
                {
                    ToolTip = 'Specifies required arrival date indicated by customer';

                }
                field("Vendor Reference"; Rec."Vendor Reference")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies vendor reference';

                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ToolTip = 'Specifies vendor invoice no.';
                }
                field("Vendor Invoice Date"; Rec."Vendor Invoice Date")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies vendor invoice date';
                }
                field("Vendor Invoice Due Date"; Rec."Vendor Invoice Due Date")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies due date for vendor invoice';
                }
                field("Status"; Rec."Status")
                {
                    ToolTip = 'Specifies current status of brokerage shipment';


                }



            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }




}