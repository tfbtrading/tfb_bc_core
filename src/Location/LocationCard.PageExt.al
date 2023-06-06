/// <summary>
/// PageExtension TFB Location Card (ID 50101) extends Record Location Card //5703.
/// </summary>
pageextension 50101 "TFB Location Card" extends "Location Card" //5703
{
    layout
    {

        addafter("Address & Contact")
        {
            group("Shipping Agents")
            {

                grid(ShippingGrid)
                {
                    GridLayout = Rows;

                    group(DefaultOptions)
                    {
                        ShowCaption = false;

                        group("Local Deliveries")
                        {
                            field("TFB Lcl Shipping Agent Code"; Rec."TFB Lcl Shipping Agent Code")
                            {
                                ApplicationArea = All;
                                Caption = 'Shipping Agent';
                                ToolTip = 'Specifies the agent to be used for local deliveries';
                            }
                            field("TFB Lcl Agent Service Code"; Rec."TFB Lcl Agent Service Code")
                            {
                                ApplicationArea = All;
                                Caption = 'Default Service Code';
                                ToolTip = 'Specifies the default service level for agent for local deliveries';
                            }

                        }

                        group("Interstate Deliveries")
                        {
                            field("TFB Insta Shipping Agent Code"; Rec."TFB Insta Shipping Agent Code")
                            {
                                ApplicationArea = All;
                                Caption = 'Shipping Agent';
                                ToolTip = 'Specifies the agent to be used for interstate deliveries';
                            }
                            field("TFB Insta Agent Service Code"; Rec."TFB Insta Agent Service Code")
                            {
                                ApplicationArea = All;
                                Caption = 'Default Service Code';
                                ToolTip = 'Specifies the default service level for agent for interstate deliveries';
                            }

                        }
                        group("Pallet Account Details")
                        {
                            field("TFB PalletExchange"; Rec.PalletExchange)
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies if customer does a pallet exchange';
                            }
                            group(PalletDetails)
                            {
                                Visible = not Rec.PalletExchange;
                                ShowCaption = false;
                                field("TFB PalletAccountType"; Rec."TFB Pallet Acct Type")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies if customer has a pallet account';
                                }

                                field("TFB PalletAccountNo"; Rec.PalletAccountNo)
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies pallet account number for specific account type';

                                }
                            }
                        }

                    }
                    group(AgentOverrideGroup)
                    {
                        ShowCaption = false;

                        part(AgentOverride; "TFB Location Agents Subform")
                        {
                            ApplicationArea = All;
                            SubPageLink = Location = field(code);
                            Caption = '';
                            Enabled = (Rec.Code <> '') and not Rec."Use As In-Transit";

                        }
                    }
                }


            }
        }
        addafter("Outbound Whse. Handling Time")
        {
            field("TFB Outbound Order Deadline"; Rec."TFB Outbound Order Deadline")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the time after which an order lines earliest dispatch day will be extended by an additional day';
            }
        }

        addbefore("Use As In-Transit")
        {
            field("TFB Enabled"; Rec."TFB Enabled")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if location is current active for shipments and receipts';

            }
            field("TFB Use for ILA"; Rec."TFB Use for ILA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if intelligent location assignment on sales line';

            }
            field("TFB Location Type"; Rec."TFB Location Type")
            {
                Importance = Promoted;
                ApplicationArea = All;
                ToolTip = 'Specifies purpose of the location';

            }
            field("TFB Location Check First"; Rec."TFB Location Check First")
            {
                Importance = Promoted;
                ApplicationArea = All;
                Caption = 'Check this location first';
                ToolTip = 'Specifies that the location should be checked first for inventory in a particular state';
            }
        }
        addafter("Inbound Whse. Handling Time")
        {
            field("TFB Quarantine Location"; Rec."TFB Quarantine Location")
            {
                ToolTip = 'Specifies if location is a warehouse for handling imports';
                ApplicationArea = All;
            }
            group("AQIS Delay Defaults")
            {
                Caption = 'Quarantine Location Details';
                ShowCaption = true;
                Visible = Rec."TFB Quarantine Location";
                field("TFB AA No."; Rec."TFB AA No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the License No. for warehouse location';
                }
                field("TFB Fumigation Time Delay"; Rec."TFB Fumigation Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delay in days waiting for fumigation to occur';
                }
                field("TFB Inspection Time Delay"; Rec."TFB Inspection Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delay in days waiting for inspection to occur';
                }
                field("TFB X-Ray Time Delay"; Rec."TFB X-Ray Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delay in days waiting for x-ray to occur';
                }
                field("TFB Heat Treat. Time Delay"; Rec."TFB Heat Treat. Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies he delay in days waiting for heat treatment to occur';
                }
            }
        }
    }

    actions
    {

    }
}