pageextension 50175 "TFB Sales Line Factbox" extends "Sales Line FactBox"
{
    layout
    {
        addafter("Required Quantity")
        {
            group(deliverydetails)
            {
                Visible = Rec.type = Rec.Type::Item;
                ShowCaption = false;

                field(DeliveryNotes; GetDeliveryNotes())
                {
                    Caption = 'Delivery Notes';
                    ToolTip = 'Specifies any additional information around delivery';
                    ApplicationArea = All;
                    DrillDown = false;
                    MultiLine = true;
                }
            }
        }
        // Add changes to page layout here
        addlast(Item)
        {
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
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
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

        If not Item.Get(Rec."No.") then exit;
        If not Customer.Get(Rec."Sell-to Customer No.") then exit;

        If Rec."Drop Shipment" then begin
            ShippingAgentServices := SalesCU.GetShippingAgentDetailsForDropShipItem(Item, Customer);
            UseDropShipDateCalcs := true;
        end;
        CustomCalendarChange[1].SetSource(Enum::"Calendar Source Type"::Location, Location.Code, '', '');

        //Add in vendor lead times until dispatch
        case UseDropShipDateCalcs of
            true:
                begin
                    If not Vendor.Get(Item."Vendor No.") then exit;

                    InfoTextBuilder.Append('Drop ship');
                    DispatchDateMin := CalendarMgmt.CalcDateBOC('', CalcDate(Vendor."TFB Dispatch Lead Time", Today), CustomCalendarChange, false);

                    If format(Vendor."TFB Dispatch Lead Time Max") = '' then
                        DispatchDateMax := DispatchDateMin
                    else
                        DispatchDateMax := CalendarMgmt.CalcDateBOC('', CalcDate(Vendor."TFB Dispatch Lead Time Max", Today), CustomCalendarChange, false);
                end;

            false:
                begin
                    If not Location.Get(Rec."Location Code") then exit;

                    ShippingAgentServices := SalesCU.GetShippingAgentDetailsForLocation(Location.Code, Customer.County, Customer."Shipment Method Code");
                    InfoTextBuilder.Append('Warehouse');

                    //Add in outbound number of days for handling

                    DispatchDateMin := Rec."Planned Shipment Date";
                    DispatchDateMax := Rec."Planned Shipment Date";

                end;
        end;




        DeliveryDateMin := CalendarMgmt.CalcDateBOC('', CalcDate(ShippingAgentServices."Shipping Time", DispatchDateMin), CustomCalendarChange, false);

        If format(ShippingAgentServices."TFB Shipping Time Max") <> '' then
            DeliveryDateMax := CalendarMgmt.CalcDateBOC('', CalcDate(ShippingAgentServices."TFB Shipping Time Max", DispatchDateMax), CustomCalendarChange, false)
        else
            DeliveryDateMax := CalendarMgmt.CalcDateBOC('', CalcDate(ShippingAgentServices."Shipping Time", DispatchDateMax), CustomCalendarChange, false);

        If ShippingAgent.Get(ShippingAgentServices."Shipping Agent Code") then
            TrackingAvailable := ShippingAgent."Internet Address" <> ''; //internet address assumed to be trackingis available

        InfoTextBuilder.Append(StrSubstNo(' dispatched between % and %2 and delivered between %3 and %4', DispatchDateMin, DispatchDateMax, DeliveryDateMin, DeliveryDateMax));
        If TrackingAvailable then
            InfoTextBuilder.Append(StrSubstNo(' with tracking available from %1', ShippingAgentServices."Shipping Agent Code"));

        Exit(InfoTextBuilder.ToText());

    end;

    trigger OnAfterGetRecord()

    var
        ItemCosting: Record "TFB Item Costing";

    begin
        clear(ItemCostingSystemID);


        ItemCosting.SetRange("Item No.", Rec."No.");
        ItemCosting.SetRange("Costing Type", ItemCosting."Costing Type"::Standard);
        If ItemCosting.Findlast() then
            ItemCostingSystemID := ItemCosting.SystemId;

    end;

    local procedure GetStandardItemCostingDescription(): Text[50]

    begin

        if not IsNullGuid(ItemCostingSystemID) then
            Exit('Exists')
        else
            Exit('Create Item Costing...');

    end;
}