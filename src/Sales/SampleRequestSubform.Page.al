page 50143 "TFB Sample Request Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "TFB Sample Request Line";
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;



                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;

                    ToolTip = 'Specifies the item number';

                    trigger OnValidate()
                    begin


                        CurrPage.Update();
                    end;
                }

                field(Description; Rec.Description)
                {
                    ToolTip = 'Description of item being sampled';
                }



                field("Use Inventory"; Rec."Use Inventory")
                {
                    Caption = 'Full Inventory Unit';
                    Enabled = Rec."No." <> '';
                    ToolTip = 'Specifies if a full inventory unit is used)';
                }


                field("Customer Sample Size"; Rec."Customer Sample Size")
                {
                    Enabled = (Rec."No." <> '') and (not Rec."Use Inventory");
                    Width = 10;
                    ToolTip = 'Specifies the size of sample in kilograms requested by customer';
                }

                field("Sourced From"; Rec."Sourced From")
                {
                    ToolTip = 'Specifies where the sample is retrieved from';
                }
                field("Source Sample Size"; Rec."Source Sample Size")

                {
                    Width = 10;
                    Enabled = (Rec."No." <> '') and ((Rec."Sourced From" = Rec."Sourced From"::Warehouse) or (Rec."Sourced From" = Rec."Sourced From"::Warehouse));
                    ToolTip = 'Specifies the size of sample in kilograms requested from source';
                }

                field("Line Status"; Rec."Line Status")
                {
                    ToolTip = 'Specifies status of retrieving this specific sample';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ItemAvailabilityBy)
            {
                Caption = '&Item Availability by';
                Image = ItemAvailability;
                Enabled = Rec."No." <> '';


                action("Event")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Event';
                    Image = "Event";
                    Enabled = Rec."No." <> '';
                
                    ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                    trigger OnAction()
                    begin
                        Item := Rec.GetItem();
                        ItemAvailFormsMgt.ShowItemAvailFromItem(Item, ItemAvailFormsMgt.ByEvent());
                    end;
                }
                action(Period)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Period';
                    Image = Period;
                    RunObject = Page "Item Availability by Periods";
                    RunPageLink = "No." = field("No.");
                    Enabled = Rec."No." <> '';
                  
                    ToolTip = 'Show the projected quantity of the item over time according to time periods, such as day, week, or month.';
                }

                action(Location)
                {
                    ApplicationArea = Location;
                    Caption = 'Location';
                    Image = Warehouse;
                 
                    Enabled = Rec."No." <> '';
                    RunObject = Page "Item Availability by Location";
                    RunPageLink = "No." = field("No."), "Drop Shipment Filter" = const(false);
                    ToolTip = 'View the actual and projected quantity of the item per location.';
                }
                action(Lot)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Lot';
                    Image = LotInfo;
                    Enabled = Rec."No." <> '';
                   
                    RunObject = Page "Item Availability by Lot No.";
                    RunPageLink = "No." = field("No.");
                    ToolTip = 'View the current and projected quantity of the item in each lot.';
                }
            }
        }
    }

    var

        Item: Record Item;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";

}