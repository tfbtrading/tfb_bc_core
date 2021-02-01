pageextension 50142 "TFB Item Availability By Event" extends "Item Availability by Event"
{
    layout
    {
        // Add changes to page layout here

        modify("Reserved Receipt")
        {
            trigger OnDrillDown()

            var

            begin
                if Rec."Reserved Receipt" > 0 then
                    ShowReservedReceipts();
            end;
        }
    }

    actions
    {
        addlast(navigation)
        {
            action("Show Reservations")
            {
                ApplicationArea = All;
                InFooterBar = true;
                Image = ItemReservation;
                ToolTip = 'Show reservations for currently selected row';



                trigger OnAction()

                var


                begin
                    ShowReservedReceipts();
                end;
            }
        }
    }

    local procedure ShowReservedReceipts()

    var
        ResEntry: Record "Reservation Entry";
        ResEntryDemand: Record "Reservation Entry";
        ResEntryPage: Page "Reservation Entries";
        TextBuider: TextBuilder;
    begin

        If Rec."Reserved Receipt" > 0 then
            case Rec.Type of
                Rec.Type::" ":
                    begin

                        ResEntry.SetRange("Source Type", 32);
                        ResEntry.SetRange("Item No.", Rec."Item No.");
                        ResEntry.SetRange(Positive, true);
                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);

                        Clear(ResEntryDemand);

                        if ResEntry.FindSet() then begin
                            repeat

                                If TextBuider.Length() > 0 then
                                    TextBuider.Append('|');

                                TextBuider.Append(Format(ResEntry."Entry No."));

                            until ResEntry.Next() < 1;

                            ResEntryDemand.SetFilter("Entry No.", TextBuider.ToText());
                            ResEntryDemand.SetRange(Positive, false);
                            ResEntryDemand.SetRange("Source Type", 37);

                            ResEntryPage.SetTableView(ResEntryDemand);
                            ResEntryPage.Run();

                        end;
                    end;

                Rec.Type::Purchase:
                    begin

                        ResEntry.SetRange("Source Type", 39);
                        ResEntry.SetRange("Source ID", Rec."Document No.");
                        ResEntry.SetRange("Item No.",Rec."Item No.");
                        ResEntry.SetRange(Positive, true);
                        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);

                        Clear(ResEntryDemand);
                        if ResEntry.FindSet() then begin
                            repeat

                                If TextBuider.Length() > 0 then
                                    TextBuider.Append('|');

                                TextBuider.Append(Format(ResEntry."Entry No."));

                            until ResEntry.Next() < 1;

                            ResEntryDemand.SetFilter("Entry No.", TextBuider.ToText());
                            ResEntryDemand.SetRange(Positive, false);
                            ResEntryDemand.SetRange("Source Type", 37);

                            ResEntryPage.SetTableView(ResEntryDemand);
                            ResEntryPage.Run();
                        end;
                    end;
                Rec.type::Transfer:
                    begin
                        Message('Show Transfer Reservations');
                        ResEntry.SetRange("Source Type", 37);
                    end;

            end;
    end;

}