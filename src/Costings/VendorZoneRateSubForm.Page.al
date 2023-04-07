page 50315 "TFB Vendor Zone Rate SubForm"
{
    caption = 'Zone Rates';
    PageType = List;
    SourceTable = "TFB Vendor Zone Rate";
    Editable = true;
    DelayedInsert = true;
    ApplicationArea = All;


    layout
    {
        area(Content)
        {

            repeater(Group)
            {
                field("Zone Code"; Rec."Zone Code")
                {
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies zone code for rate';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    Tooltip = 'Specifies sales type for rate';

                    trigger OnValidate()

                    begin
                        Rec."Sales Code" := '';
                    end;
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ToolTip = 'Specifies sales code dependant on sales type';



                    trigger OnLookup(var Text: Text): Boolean

                    var
                        RecCustomer: record Customer;
                        RecItem: record Item;

                    begin

                        case Rec."Sales Type" of
                            Rec."Sales Type"::All:
                                exit(true);

                            Rec."Sales Type"::Item:
                                begin
                                    RecItem.Reset();

                                    if PAGE.RunModal(Page::"Item List", RecItem) = Action::LookupOK then begin
                                        Text := RecItem."No.";
                                        exit(true);

                                    end;

                                end;

                            Rec."Sales Type"::Customer:
                                begin
                                    RecCustomer.Reset();

                                    if PAGE.RunModal(Page::"Customer List", RecCustomer) = Action::LookupOK then begin
                                        Text := RecCustomer."No.";
                                        exit(true);

                                    end;

                                end;



                        end;

                    end;
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ToolTip = 'Specifies type of rate type to be applied';

                    trigger OnValidate()
                    var

                        RateChangeWarning: Notification;

                    begin
                        if Rec."Surcharge Rate" > 0 then
                            if xRec."Rate Type" <> Rec."Rate Type" then begin

                                RateChangeWarning.Message('Changing the rate type will impact calculations');
                                RateChangeWarning.Scope := NotificationScope::LocalScope;
                                RateChangeWarning.Send();

                            end;
                    end;

                }

                field("Surcharge Rate"; Rec."Surcharge Rate")
                {
                    Tooltip = 'Specifies surcharge to be applied to zone';
                }
                field("Shipping Agent"; Rec."Shipping Agent")
                {
                    ToolTip = 'Specifies shipping agent related to surcharge';
                }
                field("Agent Service Code"; Rec."Agent Service Code")
                {
                    ToolTip = 'Specifies shipping agent service code to default for zone rate';
                }


            }
        }

    }

    actions
    {

    }




}