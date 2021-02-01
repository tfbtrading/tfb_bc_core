pageextension 50189 "TFB Opportunity List" extends "Opportunity List"
{

    layout
    {
        moveafter("No."; "Contact Company Name", "Contact Name")

        modify(Status)
        {
            Style = Attention;
            StyleExpr = Rec.Status = Rec.Status::"In Progress";
        }

        modify("Contact No.")
        {
            Visible = false;
        }

        modify("Contact Company No.")
        {
            Visible = false;
        }

        modify(Control45)
        {
            Visible = false;
        }

        modify("Contact Company Name")

        {



            trigger OnDrillDown()

            var
                Contact: Record Contact;

            begin

                If Contact.Get(Rec."Contact Company No.") then
                    PAGE.Run(PAGE::"Contact Card", Contact);

            end;
        }
    }


}