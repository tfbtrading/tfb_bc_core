page 50177 "TFB Location Agents Subform"
{

    PageType = ListPart;
    SourceTable = "TFB Location Shipping Agent";
    Caption = 'State Based Shipping Agent Conditions';

    Editable = true;

    ModifyAllowed = true;
    DeleteAllowed = true;
    InsertAllowed = true;
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    DrillDown = true;
                    ToolTip = 'Specifies the country to be overridden';
                    ShowMandatory = true;

                }
                field(County; Rec.County)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the state/county for which agent should be overriden';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the shipping agent to use';
                    ShowMandatory = true;
                }

                field("Agent Service Code"; Rec."Agent Service Code")
                {
                    ToolTip = 'Specifies the shipping service code to use';
                    ShowMandatory = true;
                }

            }
        }
    }



    actions
    {

    }



}