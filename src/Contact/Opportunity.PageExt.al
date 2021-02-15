pageextension 50177 "TFB Opportunity" extends "Opportunity Card"
{
    layout
    {

        addafter(General)
        {
            group(Qualification)
            {
                field("TFB Buying Reason"; Rec."TFB Buying Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the buying reason field';
                    Importance = promoted;
                }
                field("TFB Buying Timeframe"; Rec."TFB Buying Timeframe")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the buying timeframe field';
                    Importance = promoted;
                }
                field("TFB Details"; Rec."TFB Details")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the details around the opportunity';
                    Importance = standard;
                    MultiLine = true;

                }
            }
        }

        addbefore(Control25)
        {
            part(Tasks; "TFB Contact Task Subform")
            {
                SubPageLink = "Opportunity No." = field("No."), "System To-do Type" = const(Organizer), Closed = const(false);
                Caption = 'Active Tasks';
                Visible = true;
                ApplicationArea = All;
            }
        }

        movefirst(Qualification; Priority)


        modify("Contact Company Name")
        {

            Style = Strong;
            StyleExpr = Rec."Contact No." <> '';

            trigger OnDrillDown()

            var
                Contact: Record Contact;

            begin

                If Contact.Get(Rec."Contact Company No.") then
                    PAGE.Run(PAGE::"Contact Card", Contact);


            end;
        }
    }

    actions
    {
        addlast(navigation)
        {
            action(CompanyContact)
            {
                Caption = 'Company Contact';
                ApplicationArea = All;
                Image = CustomerContact;
                RunObject = page "Contact Card";
                RunPageLink = "No." = field("Contact Company No.");
                RunPageMode = View;
                ToolTip = 'Opens the company contact page';
                Enabled = Rec."Contact Company No." <> '';
            }
        }
    }


}