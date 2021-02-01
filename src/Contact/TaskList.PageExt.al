pageextension 50188 "TFB Task List" extends "Task List"
{

    
    layout
    {
        addfirst(Control1)
        {

        }
        movelast(Control1; Closed)

        movefirst(Control1; "Contact Company Name", "Contact Name")
        modify(Control55)
        {
            Visible = false;
        }

        modify("Organizer To-do No.")
        {
            Visible = false;
        }
        modify("Contact No.")
        {
            Visible = false;
        }
        modify("No.")
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}