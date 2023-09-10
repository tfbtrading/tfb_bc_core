/// <summary>
/// Codeunit TFB DS DropShip Mgmt (ID 50501).
/// </summary>
codeunit 50136 "TFB DropShip Mgmt"
{

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterUpdateShipToAddress', '', false, false)]
    /// <summary> 
    /// Description for HandleNewShipToAddress.
    /// </summary>
    /// <param name="PurchHeader">Parameter of type Record "Purchase Header".</param>
    local procedure HandleNewShipToAddress(var PurchHeader: Record "Purchase Header")
    var
        CommonCU: CodeUnit "TFB Common Library";
    begin
        //Check if ShipTo is a customer

        if (PurchHeader."Sell-to Customer No." <> '') then begin
            PurchHeader."TFB Instructions" := CommonCU.GetCustDelInstr(PurchHeader."Sell-to Customer No.", PurchHeader."Ship-to Code");
            PurchHeader.Modify(false);
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Purch.-Get Drop Shpt.", 'OnBeforePurchaseLineInsert', '', true, true)]
    /// <summary> 
    /// Event handler for Drop Ship Line Being Inserted directly on a Purchase Order
    /// </summary>
    /// <param name="PurchaseLine">Parameter of type Record "Purchase Line".</param>
    local procedure HandleDropShipLineInsert(var PurchaseLine: Record "Purchase Line")

    var
        Item: record Item;
        DeliveryZone: code[20];
        VendorSurcharge: decimal;

    begin
        if PurchaseLine."Drop Shipment" then begin
            DeliveryZone := GetDeliveryZoneForCustomerOrder(PurchaseLine."Sales Order No.");
            Item.Get(PurchaseLine."No.");


            if DeliveryZone <> '' then
                VendorSurcharge := GetVendorSurchargeforDeliveryZone(PurchaseLine."Buy-from Vendor No.", DeliveryZone, PurchaseLine."No.", PurchaseLine."Unit of Measure Code");

            if VendorSurcharge > 0 then
                PurchaseLine.Validate("Direct Unit Cost", PurchaseLine."Direct Unit Cost" + VendorSurcharge);


        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterGetDirectCost', '', false, false)]
    local procedure OnAfterGetDirectCost(var RequisitionLine: Record "Requisition Line"; CalledByFieldNo: Integer);


    var
        Item: record Item;
        PricingCU: codeunit "TFB Pricing Calculations";
        DeliveryZone: code[20];

        VendorSurcharge: decimal;
    begin


        if RequisitionLine.IsDropShipment() then begin
            DeliveryZone := GetDeliveryZoneForCustomerOrder(RequisitionLine."Sales Order No.");

            Item.Get(RequisitionLine."No.");

            if DeliveryZone <> '' then
                VendorSurcharge := GetVendorSurchargeforDeliveryZone(RequisitionLine."Vendor No.", DeliveryZone, RequisitionLine."No.", RequisitionLine."Unit of Measure Code");

            if VendorSurcharge <> 0 then begin
                RequisitionLine.Validate("Direct Unit Cost", RequisitionLine."Direct Unit Cost" + VendorSurcharge);
                RequisitionLine.CalcFields("TFB Price Unit Lookup");
                RequisitionLine."TFB Delivery Surcharge" := PricingCU.CalculatePriceUnitByUnitPrice(RequisitionLine."No.", RequisitionLine."Unit of Measure Code", RequisitionLine."TFB Price Unit Lookup", VendorSurcharge);
            end;
            RequisitionLine."TFB Sales External No." := GetSalesLineExternalNo(RequisitionLine."Sales Order No.");
        end;

    end;





    /// <summary> 
    /// Insert customer instructions into purchase order
    /// </summary>
    /// <param name="CustomerNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "text[2048]".</returns>


    /// <summary> 
    /// Determine delivery zone for customer order
    /// </summary>
    /// <param name="SalesOrderNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Code[20]".</returns>
    local procedure GetDeliveryZoneForCustomerOrder(SalesOrderNo: Code[20]): Code[20]

    var
        TFBPostcodeZone: record "TFB Postcode Zone";
        SalesHeader: record "Sales Header";

    begin
        SalesHeader.SetRange("No.", SalesOrderNo);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindFirst() then begin
            TFBPostcodeZone.SetRange("Customer Price Group", SalesHeader."Customer Price Group");
            if TFBPostcodeZone.FindFirst() then
                exit(TFBPostcodeZone.Code)

        end;
    end;

    /// <summary> 
    /// Get external customer no for sales line
    /// </summary>
    /// <param name="SalesOrderNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "Text[100]".</returns>
    local procedure GetSalesLineExternalNo(SalesOrderNo: Code[20]): Text[100];
    var
        SalesHeader: record "Sales Header";

    begin
        SalesHeader.SetRange("No.", SalesOrderNo);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindFirst() then
            exit(SalesHeader."External Document No.");

    end;

    /// <summary> 
    /// Determine vendor surcharge based on delivery zone
    /// </summary>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    /// <param name="DeliveryZoneCode">Parameter of type Code[20].</param>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="UOM">Parameter of type Code[10].</param>
    /// <returns>Return variable "Decimal".</returns>
    local procedure GetVendorSurchargeforDeliveryZone(VendorNo: Code[20]; DeliveryZoneCode: Code[20]; ItemNo: Code[20]; UOM: Code[10]): Decimal


    var
        TFBVendorZoneRate: Record "TFB Vendor Zone Rate";

        TFBPricingCalculations: CodeUnit "TFB Pricing Calculations";
        SurchargeRateBase: Decimal;

    begin

        //First check check for Delivery Zone Rate for specific customer

        TFBVendorZoneRate.SetRange("Zone Code", DeliveryZoneCode);
        TFBVendorZoneRate.SetRange("Sales Type", TFBVendorZoneRate."Sales Type"::Item);
        TFBVendorZoneRate.SetRange("Vendor No.", VendorNo);
        TFBVendorZoneRate.SetRange("Sales Code", ItemNo);

        if TFBVendorZoneRate.FindFirst() then
            SurchargeRateBase := TFBPricingCalculations.CalculateUnitPriceByPriceUnit(ItemNo, UOM, TFBVendorZoneRate."Rate Type", TFBVendorZoneRate."Surcharge Rate")

        else begin
            Clear(TFBVendorZoneRate);
            TFBVendorZoneRate.SetRange("Zone Code", DeliveryZoneCode);
            TFBVendorZoneRate.SetRange("Sales Type", TFBVendorZoneRate."Sales Type"::All);
            TFBVendorZoneRate.SetRange("Vendor No.", VendorNo);

            if TFBVendorZoneRate.FindFirst() then
                //Return Base Rate
                SurchargeRateBase := TFBPricingCalculations.CalculateUnitPriceByPriceUnit(ItemNo, UOM, TFBVendorZoneRate."Rate Type", TFBVendorZoneRate."Surcharge Rate");

        end;
        exit(SurchargeRateBase)
    end;


}