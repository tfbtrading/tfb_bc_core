
pageextension 50130 "TFB Sales Order Subform" extends "Sales Order Subform" //46
{
    layout
    {
        modify(Quantity)
        {

            trigger OnAfterValidate()

            begin
                CheckAvailabilityStatus();
            end;

        }
        addafter(Description)
        {

            field("TFB Availability"; _availability)
            {
                ApplicationArea = All;
                Caption = 'Availability';
                ShowCaption = false;
                Visible = true;
                Width = 1;
                Editable = false;
                ToolTip = 'Specifies availability on sales line';

                trigger OnDrillDown()

                var

                begin
                    if Rec.type = Rec.type::Item then
                        if not (Rec."Drop Shipment" or Rec."Special Order") then
                            Rec.ShowReservation()
                        else
                            if Rec."Purchase Order No." <> '' then
                                OpenPurchOrderForm() else
                                if Rec."Special Order Purchase No." <> '' then
                                    OpenSpecialPurchOrderForm();
                end;
            }
        }

        addafter(Quantity)
        {
            field(TrackingEmoji; CalculateTrackingEmoji)
            {
                ApplicationArea = All;
                Caption = 'Lot Okay';
                ToolTip = 'Specifies the item tracking details';
                ShowCaption = false;
                Editable = false;
                Width = 4;
                Visible = false;
                trigger OnDrillDown()

                begin
                    Rec.OpenItemTrackingLines();
                end;
            }
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
                    PurchaseLine: Record "Purchase Line";
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;


                begin

                    if PurchaseLine.Get(Enum::"Purchase Document Type"::Order, Rec."Purchase Order No.", Rec."Purch. Order Line No.") then begin
                        RecRef.GetTable(PurchaseLine);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                        CheckCoAStatus();
                    end;
                end;


            }

        }

        addafter("Unit Price")
        {
            field("Item Weight"; Rec."Net Weight")
            {
                Caption = 'Unit Weight';
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = false;
                ToolTip = 'Specifies the net weigh tof the item';
            }

            field("TFB Price Unit Cost"; Rec."TFB Price Unit Cost")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = IsInventoryItem;
                ToolTip = 'Specifies the price per kilogram of the item';
            }
            field("TFB Price Unit Discount"; Rec."TFB Price Unit Discount")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = Rec."TFB Price Unit Cost" > 0;
                Caption = 'Per Kg Discount';
                ToolTip = 'Specifies the discount as a per kilogram price';

            }
            field("TFB Pre-Order"; Rec."TFB Pre-Order")
            {
                ApplicationArea = All;
                Editable = (Rec."Drop Shipment" = false) and (Rec.type = Rec.type::Item);
                ToolTip = 'Indicates that pre-order only and price is indicative and floated to price at time of delivery';
            }

        }
    }
    actions
    {
        movelast("&Line"; "Co&mments")
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
            action("TFB Last Prices")
            {
                ApplicationArea = All;
                Image = SalesPrices;
                Caption = 'Last Prices';
                ToolTip = 'Shows the most recent prices provided to the customer';
                Enabled = (Rec.Type = Rec.Type::Item) and _lastPricesExit and (Rec."No." <> '');

                trigger OnAction()

                var
                    SalesHeader: Record "Sales Header";
                    LastPricesCU: CodeUnit "TFB Last Prices";
                    ContextRef: RecordRef;

                begin
                    ContextRef.GetTable(Rec);
                    SalesHeader.SetLoadFields("Document Date");
                    SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                    LastPricesCU.PopulateLastPrices(Enum::"TFB Last Prices Rel. Type"::Customer, Rec."Sell-to Customer No.", Rec."No.", 0, SalesHeader.RecordId, true, true, Rec."Customer Price Group");
                    LastPricesCU.ShowLastPrices(ContextRef);
                end;
            }
        }

    }

    trigger OnAfterGetRecord()

    var

    begin
        IsInventoryItem := Rec.IsInventoriableItem();
        CheckItemTrackingStatus();
        CheckAvailabilityStatus();
        CheckCoAVisibility();
        CheckCoAStatus();
        CheckLastPricesVisibility();
    end;


    trigger OnModifyRecord(): Boolean

    begin
        CheckItemTrackingStatus();
        CheckAvailabilityStatus();
        CheckCoAVisibility();
        CheckCoAStatus();
        CheckLastPricesVisibility();
    end;

    local procedure CheckLastPricesVisibility()

    var
        SalesHeader: Record "Sales Header";
        LastPricesCU: CodeUnit "TFB Last Prices";
    begin
        SalesHeader.SetLoadFields("Document Date");
        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        _lastPricesExit := LastPricesCU.CheckIfLastPriceExists(Enum::"TFB Last Prices Rel. Type"::Customer, Rec."Sell-to Customer No.", Rec."No.", 0, SalesHeader.RecordId, true, true, rec."Customer Price Group")
    end;

    local procedure CheckCoAVisibility()

    var

        Customer: Record Customer;
        PurchaseLine: Record "Purchase Line";
        PurchaseCU: CodeUnit "TFB Purchase Order Mgmt";

    begin
        if (not Rec."Drop Shipment") or (not (Rec."Purchase Order No." = '')) or (not PurchaseLine.Get(Enum::"Purchase Document Type"::Order, Rec."Purchase Order No.", Rec."Purch. Order Line No.")) then
            _isCoAVisible := false
        else
            if not (PurchaseCu.GetLineLotStatus(PurchaseLine) = _isTrackingReq::NotRequired) then begin
                if (Customer.get(Rec."Sell-to Customer No.")) and Customer."TFB CoA Required" then
                    _isCoAVisible := true
                else
                    _isCoAVisible := false;
            end
            else
                _isCoAVisible := false;
    end;

    local procedure CheckCoAStatus()

    var
        PurchaseLine: Record "Purchase Line";
        LotCU: Codeunit "TFB Lot Intelligence";

    begin
        if not _isCoAVisible then
            _isCoAReq := _isCoAReq::NotRequired
        else begin
            PurchaseLine.Get(Enum::"Purchase Document Type"::Order, Rec."Purchase Order No.", Rec."Purch. Order Line No.");
            PurchaseLine.CalcFields("Attached Doc Count");
            if PurchaseLine."Attached Doc Count" > 0 then
                _isCoAReq := _isCoAReq::ExistsNoIssue
            else
                _isCoAReq := _isCoAReq::DoesNotExist;
        end;

        _isCoARequiredEmoji := LotCU.GetEmoji(_isCoAReq);
    end;

    local procedure CheckAvailabilityStatus()


    begin
        _availability := SalesCU.GetSalesLineStatusEmoji(Rec);
    end;

    local procedure CheckItemTrackingStatus()

    begin

        if Rec.type = Rec.type::Item then begin
            TrackingOkay := LotIntelCU.CheckSalesLineItemTrackingOkay(Rec."Document No.", Rec."Line No.", Rec."Qty. to Ship (Base)");
            if TrackingOkay then
                CalculateTrackingEmoji := '✅'
            else
                CalculateTrackingEmoji := '⚠️';
        end
        else
            CalculateTrackingEmoji := '';
    end;



    var

        LotIntelCU: CodeUnit "TFB Lot Intelligence";
        SalesCU: CodeUnit "TFB Sales Mgmt";
        IsInventoryItem: Boolean;
        TrackingOkay: Boolean;
        CalculateTrackingEmoji: Text;
        _isTrackingReq: enum "TFB Lot Status";


        _isCoAVisible: Boolean;
        _availability: Text;
        _isCoARequiredEmoji: Text;
        _isCoAReq: enum "TFB Lot Status";

        _lastPricesExit: Boolean;
}