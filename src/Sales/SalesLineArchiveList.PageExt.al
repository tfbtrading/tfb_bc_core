pageextension 50147 "TFB Sales Line Archive List" extends "Sales Line Archive List"
{
    layout
    {
        addfirst(Control14)
        {
            field("Version No."; Rec."Version No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies version no.';
            }


        }
        addlast(Control14)
        {
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies purchase order no.';
            }
        }
        // Add changes to page layout here

        modify("Document No.")

        {
            trigger OnDrillDown()

            var
                SalesArchive: Record "Sales Header Archive";
                SalesArchivePage: Page "Sales Order Archive";

            begin

                SalesArchive.SetRange("No.", Rec."Document No.");
                SalesArchive.SetRange("Document Type", Rec."Document Type");
                SalesArchive.SetRange("Version No.", Rec."Version No.");

                If SalesArchive.FindFirst() then begin

                    SalesArchivePage.SetRecord(SalesArchive);
                    SalesArchivePage.Run();
                end;


            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}