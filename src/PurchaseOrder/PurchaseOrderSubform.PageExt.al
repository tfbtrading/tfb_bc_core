pageextension 50217 "TFB Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {

        addafter(Quantity)
        {
            field(TrackingEmoji; _TrackingEmoji)
            {
                Caption = 'Tracking';
                ShowCaption = false;
                ApplicationArea = All;
                ToolTip = 'Specifies lot tracking status health and link';
                Width = 1;
                Editable = false;
                Visible = _isTrackingVisible;

                trigger OnDrillDown()

                begin
                    If Rec.Type = Rec.Type::Item then
                        Rec.OpenItemTrackingLines();
                end;
            }
        }

        addlast(Control19)
        {
            field(TFBTotalQty; _TotalQty)
            {
                Caption = 'Total Qty (Base)';
                ToolTip = 'Specifies the total qty in base unit of measure of items on lines';
                ApplicationArea = All;
                Editable = false;
            }
            field(TFBTotalWeight; _TotalWeight)
            {
                Caption = 'Total Weight (net)';
                ToolTip = 'Specifies the total weight of the order in standard weight measure';
                ApplicationArea = All;
                Editable = false;
            }
        }

        addafter("Direct Unit Cost")
        {

            field("TFB Line Total Weight"; Rec."TFB Line Total Weight")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                Tooltip = 'Specifies total weight of line';
            }

            field("TFB Price Unit Lookup"; Rec."TFB Price Unit Lookup")
            {
                DrillDown = false;
                Caption = 'Vendor Price Unit';
                ApplicationArea = All;
                Editable = false;
                Tooltip = 'Specifies vendors price unit';
            }

            field("TFB Price Unit Cost"; Rec."TFB Price By Price Unit")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Tooltip = 'Specifies price in vendors price unit';

            }


        }
        addafter("Planned Receipt Date")
        {

            field("TFB Sales External No."; Rec."TFB SO Ext. No. Lookup")
            {
                ApplicationArea = All;
                Visible = Rec."Drop Shipment";
                Editable = false;
                ToolTip = 'Specifies external document number for drop shipment lines';
            }
        }
        addafter("Drop Shipment")
        {
            field("TFB COA Required"; _isCoARequiredEmoji)
            {
                ApplicationArea = All;
                Caption = 'CoA Req';
                ToolTip = 'Specifies if a CoA is required separately to the Lot';
                Width = 4;
                Visible = _isCoAVisible;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin

                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                    CheckCoAStatus();

                end;


            }
        }

    }


    actions
    {
        addlast("&Line")
        {
            action(History)
            {
                ApplicationArea = All;
                Image = History;
                Caption = 'History';
                ToolTip = 'Shows the history in the change log for the item';
                Enabled = not (Rec.Type = Rec.Type::" ");

                trigger OnAction()

                var
                    CommonCU: CodeUnit "TFB Common Library";
                begin

                    CommonCU.ShowValueHistory(Rec.RecordId());

                end;
            }
        }
    }

    trigger OnAfterGetRecord()

    var

        PurchaseCU: CodeUnit "TFB Purchase Order Mgmt";


    begin


        _isTrackingReq := PurchaseCU.GetLineLotStatus(Rec);
        case _isTrackingReq of
            _isTrackingReq::NotRequired:
                _isTrackingVisible := false;

            else
                _isTrackingVisible := true;
        end;
        _trackingEmoji := LotCU.GetEmoji(_isTrackingReq);
        CheckCoAVisibility();
        CheckCoAStatus();
        UpdateTotalQty();

    end;

    local procedure UpdateTotalQty()

    begin
        PurchaseLine.CopyFilters(Rec);
        PurchaseLine.CalcSums("Quantity (Base)");
        PurchaseLine.CalcSums("TFB Line Total Weight");
        _TotalQty := PurchaseLine."Quantity (Base)";
        _TotalWeight := PurchaseLine."TFB Line Total Weight";
    end;

    var
        PurchaseLine: record "Purchase Line";
        LotCU: Codeunit "TFB Lot Intelligence";
        _isTrackingReq: enum "TFB Lot Status";
        _isCoAReq: enum "TFB Lot Status";

        _isCoAVisible: Boolean;
        _isTrackingVisible: Boolean;
        _TotalQty: Decimal;
        _TotalWeight: Decimal;
        _trackingEmoji: Text;
        _isCoARequiredEmoji: Text;

    local procedure CheckCoAVisibility()

    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;

    begin
        If (not Rec."Drop Shipment") or (Rec."Sales Order No." = '') then
            _isCoAVisible := false
        else
            if not _isTrackingVisible then begin
                SalesHeader.SetRange("Document Type", Rec."Document Type");
                SalesHeader.SetRange("No.", Rec."Sales Order No.");
                if SalesHeader.FindFirst() and (Customer.get(SalesHeader."Sell-to Customer No.")) and Customer."TFB CoA Required" then
                    _isCoAVisible := true
                else
                    _isCoAVisible := false;
            end
            else
                _isCoAVisible := false;
    end;

    local procedure CheckCoAStatus()

    var

    begin
        If not _isCoAVisible then
            _isCoAReq := _isCoAReq::NotRequired
        else begin
            Rec.CalcFields("Attached Doc Count");
            If Rec."Attached Doc Count" > 0 then
                _isCoAReq := _isCoAReq::ExistsNoIssue
            else
                _isCoAReq := _isCoAReq::DoesNotExist;
        end;

        _isCoARequiredEmoji := LotCU.GetEmoji(_isCoAReq);
    end;

}