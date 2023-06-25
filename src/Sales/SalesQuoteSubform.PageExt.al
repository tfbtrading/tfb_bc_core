pageextension 50131 "TFB Sales Quote Subform" extends "Sales Quote Subform" //95
{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field("Planned Shipment Date"; Rec."Planned Shipment Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the planned date for shipment';

            }
        }
        addafter("Unit Price")
        {
            field("TFBItem Weight"; Rec."Net Weight")
            {
                Caption = 'Unit Weight';
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Enabled = false;
                ToolTip = 'Specifies the item net weight';
            }

            field("TFB Price Unit Cost"; Rec."TFB Price Unit Cost")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                ToolTip = 'Specifies the per kg item cost';
            }

            field("TFB Price Unit Discount"; Rec."TFB Price Unit Discount")
            {
                ApplicationArea = All;
                BlankNumbers = BlankZero;
                Editable = Rec."TFB Price Unit Cost" > 0;
                Caption = 'Per Kg Discount';
                ToolTip = 'Specifies the discount as a per kilogram price';

            }
        }


    }



    actions
    {
        modify("Assemble to Order")
        {
            Visible = false;
        }
        modify("Item Charge &Assignment")
        {
            Visible = false;
        }
        modify("E&xplode BOM")
        {
            Visible = false;
        }
        addafter("F&unctions")
        {
            action("&Check Availability Date")
            {
                Visible = true;
                Caption = 'Availability to Promise';
                ToolTip = 'Opens availability dialog';
                Image = AvailableToPromise;
                ApplicationArea = All;

                trigger OnAction()

                var
                    Item: Record Item;
                    CustCal: Record "Customized Calendar Change";
                    AvailableToPromise: CodeUnit "Available to Promise";
                    CalCU: Codeunit "Calendar Management";
                    DF, DF2 : DateFormula;
                    FoundDate: Boolean;
                    AvailableQty: Decimal;
                    AvailableDate: Date;


                begin
                    FoundDate := false;
                    Evaluate(DF, '+3M');
                    Evaluate(DF2, '+1D');
                    if Item.Get(rec."No.") then begin
                        AvailableDate := AvailableToPromise.CalcEarliestAvailabilityDate(Item, rec.Quantity, rec."Planned Shipment Date", 0, 0D, AvailableQty, Enum::"Analysis Period Type"::Day, DF);


                        if AvailableDate > 0D then
                            if AvailableDate = Today() then
                                Message('Quantity is available for prompt')
                            else
                                if Confirm('There are %1 available on %2. Change to this date?', true, AvailableQty, AvailableDate) then begin
                                    repeat
                                        AvailableDate := CalcDate(DF2, AvailableDate);
                                        CustCal.SetSource(CustCal."Source Type"::Location, Rec."Location Code", '', '');
                                        if not CalCU.IsNonworkingDay(AvailableDate, CustCal) then
                                            FoundDate := true;
                                    until FoundDate = true;
                                    Rec.validate("Planned Shipment Date", AvailableDate);
                                end;
                    end;
                end;

            }
        }
        addlast("&Line")
        {
            action("TFB Last Prices")
            {
                ApplicationArea = All;
                Image = SalesPrices;
                Caption = 'Last Prices';
                ToolTip = 'Shows the most recent prices provided to the customer';
                Enabled = Rec.Type = Rec.Type::Item;

                trigger OnAction()

                var
                    LastPricesCU: CodeUnit "TFB Last Prices";
                    SalesHeader: Record "Sales Header";
                    ContextRef: RecordRef;

                begin
                    ContextRef.GetTable(Rec);
                    SalesHeader.SetLoadFields("Document Date");
                    SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                    LastPricesCU.PopulateLastPrices(Enum::"TFB Last Prices Rel. Type"::Customer, Rec."Sell-to Customer No.", Rec."No.", 0, SalesHeader.RecordId, true);
                    LastPricesCU.ShowLastPrices(ContextRef);
                end;
            }
        }
    }
}