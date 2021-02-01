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
                    CU: CodeUnit "Available to Promise";
                    CalCU: Codeunit "Calendar Management";
                    DF, DF2 : DateFormula;
                    FoundDate: Boolean;
                    AvailableQty: Decimal;
                    AvailableDate: Date;


                begin
                    FoundDate := false;
                    Evaluate(DF, '+3M');
                    Evaluate(DF2, '+1D');
                    If Item.Get(rec."No.") then begin
                        AvailableDate := cu.EarliestAvailabilityDate(Item, rec.Quantity, rec."Planned Shipment Date", 0, 0D, AvailableQty, 1, DF);


                        If AvailableDate > 0D then
                            If AvailableDate = Today() then
                                Message('Quantity is available for prompt')
                            else
                                If Confirm('There are %1 available on %2. Change to this date?', true, AvailableQty, AvailableDate) then begin
                                    repeat
                                        AvailableDate := CalcDate(DF2, AvailableDate);
                                        CustCal.SetSource(CustCal."Source Type"::Location, Rec."Location Code", '', '');
                                        If not CalCU.IsNonworkingDay(AvailableDate, CustCal) then
                                            FoundDate := true;
                                    until FoundDate = true;
                                    Rec.validate("Planned Shipment Date", AvailableDate);
                                end;
                    end;
                end;

            }
        }
    }
}