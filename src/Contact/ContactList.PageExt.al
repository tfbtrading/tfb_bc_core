pageextension 50109 "TFB ContactList" extends "Contact List" //MyTargetPageId
{
    layout
    {
        addafter(Name)
        {
            Field(ToDoExists; GetTaskSymbol())
            {
                Caption = '';
                Width = 1;
                ShowCaption = false;
                ToolTip = 'Specifies if a task exists';
                DrillDown = false;
                ApplicationArea = All;

            }
        }

        modify("No.")
        {
            Visible = false;
        }
        addafter("Company Name")
        {
          
            field("TFB Is Customer"; Rec."TFB Is Customer")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies if record is a customer';
                BlankZero = true;

                trigger OnDrillDown()

                var
                    BusRel: Record "Contact Business Relation";
                    Customer: Record Customer;

                begin

                    BusRel.SetRange("Contact No.", Rec."Company No.");
                    BusRel.SetRange("Link to Table", BusRel."Link to Table"::Customer);

                    If BusRel.FindFirst() and Customer.Get(BusRel."No.") then
                        PAGE.Run(PAGE::"Customer Card", Customer);


                end;

            }
            field("TFB Contact Status"; Rec."TFB Contact Status")
            {
                ApplicationArea = All;
                Editable = true;
                Tooltip = 'Specifies contact status';

            }
            field("Last Date Attempted"; Rec."Last Date Attempted")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies last date attempted to reach contact';
                Visible = false;
            }
        }


    }



    actions
    {
    }
    views
    {
        addlast
        {
            view(ContactWithTasks)
            {
                Caption = 'Contacts With Open Tasks';
                Filters = where("TFB No. Of Company Tasks" = filter('>0'), Type = const(Company));
                SharedLayout = true;
            }

            view(ContactsPendingInteraction)
            {
                Caption = 'Contacts Requiring Followup';
                Filters = where("Last Date Attempted" = filter('<>'''''), "Date of Last Interaction" = filter(''), Type = const(Company));
                SharedLayout = false;
                layout
                {
                    modify("Last Date Attempted")
                    {
                        Visible = true;
                    }
                    moveafter("TFB Contact Status"; "Last Date Attempted")

                }
            }
        }
    }

    local procedure GetTaskSymbol(): Text

    var
        Contact: Record Contact;

    begin

        Contact.SetLoadFields("TFB No. Of Company Tasks", "TFB No. Of Contact Tasks", "No.");
        Contact.SetAutoCalcFields("TFB No. Of Company Tasks", "TFB No. Of Contact Tasks");
        Rec.CalcFields("TFB No. Of Company Tasks");
        If Rec.Type = Rec.Type::Company then
            If Rec."TFB No. Of Company Tasks" > 0 then
                Exit('📋')
            else
                Exit('')
        else
            If Contact."TFB No. Of Contact Tasks" > 0 then
                Exit('📋')
            else
                Exit('');
    end;
}