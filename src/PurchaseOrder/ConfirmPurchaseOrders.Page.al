page 50124 "TFB Confirm Purchase Orders"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Purchase Header";
    SourceTableView = sorting("No.", "Document Type") order(descending) where("Document Type" = const(Order), "Completely Received" = const(false));
    Editable = true;
    DeleteAllowed = true;
    InsertAllowed = false;
    Caption = 'Confirm Purchase Orders';
    CardPageId = "Purchase Order";
    Extensible = true;
    AdditionalSearchTerms = 'Update Vendor Order No';
    ModifyAllowed = true;
    ShowFilter = true;

    layout
    {
        area(Content)
        {
            repeater(Orders)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the purchase order number';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = rec."TFB Manual Confirmation" = true;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ToolTip = 'Specifies the buy-from vendor';
                    editable = false;
                    DrillDown = true;
                    DrillDownPageId = "Vendor Card";
                    Lookup = true;
                    LookupPageId = "Vendor Card";
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ToolTip = 'Specifies the name of the vendor';
                    Editable = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ToolTip = 'Specifies the location goods are being shipped to';
                    Editable = false;
                }
                field(TFBVendorPref; GetVendorConfirmPreference())
                {
                    Caption = 'Vendor provides reference no.';
                    Editable = false;
                    Tooltip = 'Specifies wether the vendor is expected to provide a reference';

                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    Tooltip = 'Specifies the vendor order number';
                    Editable = true;

                }
                field("TFB Manual Confirmation"; Rec."TFB Manual Confirmation")
                {
                    Caption = 'Order confirmed by vendor';
                    ToolTip = 'Specifies whether the order has been confirmed';
                    Editable = true;
                }
                field("Requested Receipt Date"; GetLineDate())
                {
                    Caption = 'Requested Receipt Date on Line';
                    ToolTip = 'Specifies the requested date for receipt';
                    Editable = false;
                }
                field("Promised Receipt Date"; Rec."Promised Receipt Date")
                {
                    ToolTip = 'Specifies the date that receipt is promised';
                    Editable = true;
                }
                field("LinesDesc"; GetOrderLines())
                {
                    ToolTip = 'Specifies the lines on the order';
                    MultiLine = false;
                    Editable = false;
                    Caption = 'Lines';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    Tooltip = 'Specifies the total amount of the order';
                    Editable = false;
                }
            }
        }
        area(Factboxes)
        {
            systempart(notes; Notes)
            {
            }
            systempart(attachments; Links)
            {
            }

            part("Attached Documents"; "Document Attachment Factbox")
            {
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(38),
                              "No." = field("No."),
                              "Document Type" = field("Document Type");
            }

        }

    }



    actions
    {


    }

    views
    {
        view(Unconfirmed)
        {
            Caption = 'Unconfirmed orders';
            SharedLayout = true;
            filters = where("Vendor Order No." = filter(''));
        }

    }



    local procedure GetVendorConfirmPreference(): Boolean

    var

        Vendor: Record Vendor;

    begin

        if Vendor.Get(Rec."Buy-from Vendor No.") then
            exit(Vendor."TFB Vendor Provides Ref.");
    end;

    local procedure GetLineDate(): Date;

    var
        PurchaseLines: Record "Purchase Line";


    begin
        PurchaseLines.SetRange("Document Type", Rec."Document Type");
        PurchaseLines.SetRange("Document No.", Rec."No.");
        if PurchaseLines.FindFirst() then
            exit(PurchaseLines."Expected Receipt Date");
    end;

    local procedure GetOrderLines(): Text

    var
        PurchaseLines: Record "Purchase Line";
        LineBuilder: TextBuilder;

    begin
        PurchaseLines.SetRange("Document Type", Rec."Document Type");
        PurchaseLines.SetRange("Document No.", Rec."No.");
        if PurchaseLines.Findset(false) then
            repeat

                LineBuilder.AppendLine(StrSubstNo('%1 - %2 %3', PurchaseLines.Description, PurchaseLines.Quantity, PurchaseLines."Unit of Measure"));

            until PurchaseLines.Next() = 0;
        exit(LineBuilder.ToText());
    end;
}