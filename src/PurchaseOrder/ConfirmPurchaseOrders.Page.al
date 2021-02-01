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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase order number';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = rec."TFB Manual Confirmation" = true;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the buy-from vendor';
                    editable = false;
                    DrillDown = true;
                    DrillDownPageId = "Vendor Card";
                    Lookup = true;
                    LookupPageId = "Vendor Card";
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the vendor';
                    Editable = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location goods are being shipped to';
                    Editable = false;
                }
                field(TFBVendorPref; GetVendorConfirmPreference())
                {
                    ApplicationArea = all;
                    Caption = 'Vendor provides reference no.';
                    Editable = false;
                    Tooltip = 'Specifies wether the vendor is expected to provide a reference';

                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the vendor order number';
                    Editable = true;

                }
                field("TFB Manual Confirmation"; Rec."TFB Manual Confirmation")
                {
                    ApplicationArea = All;
                    Caption = 'Order confirmed by vendor';
                    ToolTip = 'Specifies whether the order has been confirmed';
                    Editable = true;
                }
                field("Requested Receipt Date"; GetLineDate())
                {
                    ApplicationArea = All;
                    Caption = 'Requested Receipt Date on Line';
                    ToolTip = 'Specifies the requested date for receipt';
                    Editable = false;
                }
                field("Promised Receipt Date"; Rec."Promised Receipt Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the date that receipt is promised';
                    Editable = true;
                }
                field("LinesDesc"; GetOrderLines())
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lines on the order';
                    MultiLine = false;
                    Editable = false;
                    Caption = 'Lines';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the total amount of the order';
                    Editable = false;
                }
            }
        }
        area(Factboxes)
        {
            systempart(notes; Notes)
            {
                ApplicationArea = All;
            }
            systempart(attachments; Links)
            {
                ApplicationArea = All;
            }

            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(38),
                              "No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
            }

        }

    }



    actions
    {
        area(Processing)
        {
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = New;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }

    }

    views
    {
        view(Unconfirmed)
        {
            Caption = 'Unconfirmed orders';
            SharedLayout = true;
            filters = WHERE("Vendor Order No." = filter(''));
        }

    }



    Local Procedure GetVendorConfirmPreference(): Boolean

    var

        Vendor: Record Vendor;

    begin

        If Vendor.Get(Rec."Buy-from Vendor No.") then
            Exit(Vendor."TFB Vendor Provides Ref.");
    end;

    Local Procedure GetLineDate(): Date;

    var
        PurchaseLines: Record "Purchase Line";


    begin
        PurchaseLines.SetRange("Document Type", Rec."Document Type");
        PurchaseLines.SetRange("Document No.", Rec."No.");
        If PurchaseLines.FindFirst() then
            Exit(PurchaseLines."Expected Receipt Date");
    end;

    Local Procedure GetOrderLines(): Text

    var
        PurchaseLines: Record "Purchase Line";
        LineBuilder: TextBuilder;

    begin
        PurchaseLines.SetRange("Document Type", Rec."Document Type");
        PurchaseLines.SetRange("Document No.", Rec."No.");
        If PurchaseLines.Findset(false, false) then
            repeat

                LineBuilder.AppendLine(StrSubstNo('%1 - %2 %3', PurchaseLines.Description, PurchaseLines.Quantity, PurchaseLines."Unit of Measure"));

            until PurchaseLines.Next() = 0;
        exit(LineBuilder.ToText());
    end;
}