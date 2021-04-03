codeunit 50107 "TFB Item Mgmt"
{
    trigger OnRun()
    begin


    end;

    

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterCopyFromItem', '', true, true)]

    local procedure HandleOnAfterCopyFromItem(Item: Record Item; var SalesLine: Record "Sales Line")

    var


    begin
        //SalesLine.Validate("Purchasing Code", Item."TFB Default Purch. Code"); //No longer required
        UpdateDropShipSalesLineAgent(Item, SalesLine);
    end;

    internal procedure UpdateDropShipSalesLineAgent(Item: Record Item; var SalesLine: Record "Sales Line"): Boolean

    var
        Vendor: Record Vendor;
        ShippingAgent: Record "Shipping Agent";
        AgentServices: Record "Shipping Agent Services";
        PostcodeZone: Record "TFB Postcode Zone";

    begin
        if Item.Get(SalesLine."No.") then
            if SalesLine."Drop Shipment" = true then

                //Check if there is an override shipping agent and service

                If Vendor.Get(Item."Vendor No.") then
                    If GetZoneRateForSalesLine(SalesLine, PostcodeZone) then
                        If GetVendorShippingAgentOverride(Vendor."No.", PostcodeZone.Code, AgentServices) then begin
                            SalesLine.Validate("Shipping Agent Code", AgentServices."Shipping Agent Code");
                            Salesline.validate("Shipping Agent Service Code", AgentServices.Code);
                        end
                        else
                            //if no override exists but here is a valid vendor then use default service for vendor
                            If ShippingAgent.Get(Vendor."Shipping Agent Code") then begin
                                SalesLine.Validate("Shipping Agent Code", ShippingAgent.Code);
                                Salesline.validate("Shipping Agent Service Code", ShippingAgent."TFB Service Default");
                            end;

    end;

    local procedure GetZoneRateForSalesLine(SalesLine: Record "Sales Line"; var PostcodeZone: Record "TFB Postcode Zone"): Boolean

    var
        SalesHeader: Record "Sales Header";

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SalesLine."Document No.");

        If SalesHeader.FindFirst() then begin

            PostcodeZone.SetRange("Customer Price Group", SalesHeader."Customer Price Group");

            If PostcodeZone.FindFirst() then
                Exit(true);
        end;

    end;

    local procedure GetVendorShippingAgentOverride(VendorNo: Code[20]; ShippingZone: Code[20]; var AgentServices: Record "Shipping Agent Services"): Boolean

    var
        VendorZoneRate: Record "TFB Vendor Zone Rate";

    begin

        VendorZoneRate.SetRange("Sales Type", VendorZoneRate."Sales Type"::All);
        VendorZoneRate.SetRange("Zone Code", ShippingZone);
        VendorZoneRate.SetRange("Vendor No.", VendorNo);

        If VendorZoneRate.FindFirst() then
            If VendorZoneRate."Agent Service Code" <> '' then begin
                AgentServices.SetRange("Shipping Agent Code", VendorZoneRate."Shipping Agent");
                AgentServices.SetRange(Code, VendorZoneRate."Agent Service Code");

                If AgentServices.FindFirst() then
                    Exit(true);

            end;
    end;

    procedure GetItemDynamicDetails(ItemNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date)

    var
        SalesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        SalesPriceRec: Record "Sales Price";
        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin
        SalesSetup.Get();


        Clear(SalesPriceRec);


        If (SalesSetup."TFB Def. Customer Price Group" <> '') and Item.Get(ItemNo) then begin

            SalesPriceRec.SetRange("Item No.", ItemNo);
            SalesPriceRec.SetRange("Sales Code", SalesSetup."TFB Def. Customer Price Group");
            SalesPriceRec.SetRange("Sales Type", SalesPriceRec."Sales Type"::"Customer Price Group");
            SalesPriceRec.SetRange("Ending Date", 0D);

            If SalesPriceRec.FindLast() then begin
                SalesPrice := PricingCU.CalcPerKgFromUnit(SalesPriceRec."Unit Price", Item."Net Weight");
                LastChanged := SalesPriceRec."Starting Date";
            end;
        end;



    end;


    procedure GetItemDynamicDetails(ItemNo: Code[20]; CustNo: Code[20]; var SalesPrice: Decimal; var LastChanged: Date; var LastPricePaid: Decimal; var LastDatePurchased: Date)

    var

        SalesInvoiceLine: Record "Sales Invoice Line";
        Item: Record Item;
        PricingCU: CodeUnit "TFB Pricing Calculations";
    begin

        GetItemDynamicDetails(ItemNo, SalesPrice, LastChanged);


        SalesInvoiceLine.SetRange("Sell-to Customer No.", CustNo);
        SalesInvoiceLine.SetRange("No.", ItemNo);
        SalesInvoiceLine.SetCurrentKey("Posting Date");
        SalesInvoiceLine.SetAscending("Posting Date", false);

        If SalesInvoiceLine.FindFirst() and Item.Get(ItemNo) then begin
            LastPricePaid := PricingCU.CalcPerKgFromUnit(SalesInvoiceLine."Unit Price", SalesInvoiceLine."Net Weight");
            LastDatePurchased := SalesInvoiceLine."Posting Date";
        end;
    end;

}