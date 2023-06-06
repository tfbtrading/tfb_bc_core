/// <summary>
/// PageExtension TFB Sales Line Factbox (ID 50175) extends Record Sales Line FactBox.
/// </summary>
pageextension 50175 "TFB Sales Line Factbox" extends "Sales Line FactBox"
{
    layout
    {
        addafter("Required Quantity")
        {
            field("TFB No. Of Comments"; Rec."TFB No. Of Comments")
            {
                ToolTip = 'Specifies the number of sales line comments added if they exist';
                Caption = 'No. Of Comments';
                ApplicationArea = All;


                trigger OnDrillDown()

                begin
                    Rec.CalcFields("TFB No. Of Comments");
                    if Rec."TFB No. Of Comments" > 0 then
                        Rec.ShowLineComments();
                end;

            }
            group(deliverydetails)
            {
                Visible = (Rec.type = Rec.Type::Item) and (Rec."Document Type" = Rec."Document Type"::Order);
                ShowCaption = false;

                field(DeliveryNotes; GetDeliveryNotes() <> '')
                {
                    Caption = 'Delivery Notes';
                    ToolTip = 'Specifies any additional information around delivery';
                    ApplicationArea = All;
                    DrillDown = true;
                    MultiLine = true;


                    trigger OnDrillDown()

                    var

                    begin
                        Message(GetDeliveryNotes());
                    end;
                }
            }
        }
        // Add changes to page layout here
        addlast(Item)
        {
            field(TFBOnQuote; GetNoOfQuotesOpen())
            {
                Caption = 'No. of Open Quotes';
                ToolTip = 'Specifies number of quotes that include this item';
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()

                var

                    QuoteLine: record "Sales Line";
                    Quote: record "Sales Header";
                    QuoteList: page "Sales Quotes";
                    FilterToken: TextBuilder;
                begin

                    QuoteLine.SetRange("No.", Rec."No.");
                    QuoteLine.SetRange("Document Type", Rec."Document Type"::Quote);
                    QuoteLine.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");

                    if QuoteLine.IsEmpty() then exit;
                    QuoteLine.SetLoadFields("Document No.");
                    QuoteLine.FindSet();
                    repeat
                        if FilterToken.Length = 0 then
                            FilterToken.Append('=' + QuoteLine."Document No.")
                        else
                            FilterToken.Append('|' + QuoteLine."Document No.");
                    until QuoteLine.Next() = 0;

                    Quote.SetFilter("No.", FilterToken.ToText());
                    Quote.SetRange("Document Type", Quote."Document Type"::Quote);
                    Quote.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");
                    QuoteList.SetTableView(Quote);
                    QuoteList.Run();

                end;
            }

            field(TFBBlanketOrder; GetNoOpenOpenBlanketOrders())
            {
                Caption = 'No. Of Blanket Orders';
                ToolTip = 'Specifies blanket orders applicable to this item';
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    SalesLine: Record "Sales Line";
                    BlanketOrder: record "Sales Header";
                    BlanketOrderList: page "Blanket Sales Orders";
                    FilterToken: TextBuilder;
                begin

                    SalesLine.SetRange("No.", Rec."No.");
                    SalesLine.SetRange("Document Type", Rec."Document Type"::"Blanket Order");
                    SalesLine.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");

                    if SalesLine.IsEmpty() then exit;
                    SalesLine.SetLoadFields("Document No.");
                    SalesLine.FindSet();
                    repeat
                        if FilterToken.Length = 0 then
                            FilterToken.Append('=' + SalesLine."Document No.")
                        else
                            FilterToken.Append('|' + SalesLine."Document No.");
                    until SalesLine.Next() = 0;

                    BlanketOrder.SetFilter("No.", FilterToken.ToText());
                    BlanketOrder.SetRange("Document Type", BlanketOrder."Document Type"::"Blanket Order");
                    BlanketOrder.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");
                    BlanketOrderList.SetTableView(BlanketOrder);
                    BlanketOrderList.Run();


                end;
            }
            field(TFBItemCostingSystemID; GetStandardItemCostingDescription())
            {
                Caption = 'Costing calculation';
                ToolTip = 'Specifies if an item costings exists and links  to it';
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()

                var
                    ItemCosting: record "TFB Item Costing";
                    ItemCostingPage: page "TFB Item Costing";
                begin

                    if ItemCosting.GetBySystemId(ItemCostingSystemID) then begin
                        ItemCostingPage.SetRecord(ItemCosting);
                        ItemCostingPage.Run();
                    end
                    else begin
                        ItemCosting.Init();
                        ItemCosting.Validate("Item No.", Rec."No.");
                        ItemCosting.Validate("Costing Type", ItemCosting."Costing Type"::Standard);
                        ItemCosting.Validate("Effective Date", WorkDate());
                        ItemCostingPage.SetRecord(ItemCosting);
                        ItemCostingPage.Run();
                    end;
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        ItemCostingSystemID: Guid;


    local procedure GetDeliveryNotes(): Text
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        Vendor: Record Vendor;
        Item: Record Item;
        Customer: Record Customer;
        CustomCalendarChange: array[2] of Record "Customized Calendar Change";
        ShippingAgent: Record "Shipping Agent";
        Location: record Location;
        SalesCU: CodeUnit "TFB Sales Mgmt";
        CalendarMgmt: CodeUnit "Calendar Management";

        DispatchDateMin: Date;
        DispatchDateMax: Date;
        DeliveryDateMin: Date;
        DeliveryDateMax: Date;
        UseDropShipDateCalcs: Boolean;
        TrackingAvailable: Boolean;
        InfoTextBuilder: TextBuilder;

    begin

        if not Item.Get(Rec."No.") then exit;
        if not Customer.Get(Rec."Sell-to Customer No.") then exit;

        if Rec."Drop Shipment" then begin
            ShippingAgentServices := SalesCU.GetShippingAgentDetailsForDropShipItem(Item, Customer);
            UseDropShipDateCalcs := true;
        end;
        CustomCalendarChange[1].SetSource(Enum::"Calendar Source Type"::Location, Location.Code, '', '');

        //Add in vendor lead times until dispatch
        case UseDropShipDateCalcs of
            true:
                begin
                    if not Vendor.Get(Item."Vendor No.") then exit;

                    InfoTextBuilder.Append('Drop ship');
                    DispatchDateMin := CalendarMgmt.CalcDateBOC('', CalcDate(Vendor."TFB Dispatch Lead Time", Today), CustomCalendarChange, false);

                    if format(Vendor."TFB Dispatch Lead Time Max") = '' then
                        DispatchDateMax := DispatchDateMin
                    else
                        DispatchDateMax := CalendarMgmt.CalcDateBOC('', CalcDate(Vendor."TFB Dispatch Lead Time Max", Today), CustomCalendarChange, false);
                end;

            false:
                begin
                    if not Location.Get(Rec."Location Code") then exit;

                    ShippingAgentServices := SalesCU.GetShippingAgentDetailsForLocation(Location.Code, Customer.County, Customer."Shipment Method Code", true);
                    InfoTextBuilder.Append('Warehouse');

                    //Add in outbound number of days for handling

                    DispatchDateMin := Rec."Planned Shipment Date";
                    DispatchDateMax := Rec."Planned Shipment Date";

                end;
        end;




        DeliveryDateMin := CalendarMgmt.CalcDateBOC('', CalcDate(ShippingAgentServices."Shipping Time", DispatchDateMin), CustomCalendarChange, false);

        if format(ShippingAgentServices."TFB Shipping Time Max") <> '' then
            DeliveryDateMax := CalendarMgmt.CalcDateBOC('', CalcDate(ShippingAgentServices."TFB Shipping Time Max", DispatchDateMax), CustomCalendarChange, false)
        else
            DeliveryDateMax := CalendarMgmt.CalcDateBOC('', CalcDate(ShippingAgentServices."Shipping Time", DispatchDateMax), CustomCalendarChange, false);

        if ShippingAgent.Get(ShippingAgentServices."Shipping Agent Code") then
            TrackingAvailable := ShippingAgent."Internet Address" <> ''; //internet address assumed to be trackingis available

        InfoTextBuilder.Append(StrSubstNo(' dispatched between %1 and %2 and delivered between %3 and %4', DispatchDateMin, DispatchDateMax, DeliveryDateMin, DeliveryDateMax));
        if TrackingAvailable then
            InfoTextBuilder.Append(StrSubstNo(' with tracking available from %1', ShippingAgentServices."Shipping Agent Code"));

        exit(InfoTextBuilder.ToText());

    end;

    trigger OnAfterGetRecord()

    var
        ItemCosting: Record "TFB Item Costing";

    begin
        clear(ItemCostingSystemID);


        ItemCosting.SetRange("Item No.", Rec."No.");
        ItemCosting.SetRange("Costing Type", ItemCosting."Costing Type"::Standard);
        if ItemCosting.Findlast() then
            ItemCostingSystemID := ItemCosting.SystemId;

    end;

    local procedure GetStandardItemCostingDescription(): Text[50]

    begin

        if not IsNullGuid(ItemCostingSystemID) then
            exit('Exists')
        else
            exit('Create Item Costing...');

    end;

    local procedure GetNoOfQuotesOpen(): Integer

    var

        QuoteLine: record "Sales Line";

    begin

        QuoteLine.SetRange("No.", Rec."No.");
        QuoteLine.SetRange("Document Type", Rec."Document Type"::Quote);
        exit(QuoteLine.Count());

    end;

    local procedure GetNoOpenOpenBlanketOrders(): Integer

    var

        SalesLine: Record "Sales Line";

    begin

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Blanket Order");
        SalesLine.SetRange("No.", Rec."No.");
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        exit(SalesLine.Count());

    end;
}