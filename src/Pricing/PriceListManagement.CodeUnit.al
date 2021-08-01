codeunit 50116 "TFB Price List Management"
{
    trigger OnRun()
    begin

    end;

    procedure AddLines(var PriceListHeader: Record "Price List Header")
    var
        PriceLineFilters: Record "Price Line Filters";
        SuggestPriceLine: Page "Suggest Price Lines";
    begin
        PriceLineFilters.Worksheet := PriceListHeader.IsTemporary();
        if PriceLineFilters.Worksheet then
            SuggestPriceLine.SetDefaults(PriceListHeader);
        PriceLineFilters.Initialize(PriceListHeader, false);
        SuggestPriceLine.SetRecord(PriceLineFilters);
        if SuggestPriceLine.RunModal() = Action::OK then begin
            SuggestPriceLine.GetRecord(PriceLineFilters);
            SuggestPriceLine.GetDefaults(PriceListHeader);
            AddLines(PriceListHeader, PriceLineFilters);
        end;
    end;

    procedure AddLines(var ToPriceListHeader: Record "Price List Header"; PriceLineFilters: Record "Price Line Filters")
    var
        PriceAsset: Record "Price Asset";
        RecRef: RecordRef;
    begin
        RecRef.Open(PriceLineFilters."Table Id");
        if PriceLineFilters."Asset Filter" <> '' then
            RecRef.SetView(PriceLineFilters."Asset Filter");
        if RecRef.FindSet() then begin
            PriceAsset."Price Type" := ToPriceListHeader."Price Type";
            PriceAsset.Validate("Asset Type", PriceLineFilters."Asset Type");
            repeat
                PriceAsset.Validate("Asset ID", RecRef.Field(RecRef.SystemIdNo()).Value());
                if PriceAsset."Asset No." <> '' then
                    AddLine(ToPriceListHeader, PriceAsset, PriceLineFilters);
            until RecRef.Next() = 0;
        end;
        RecRef.Close();
    end;

    local procedure AddLine(ToPriceListHeader: Record "Price List Header"; PriceAsset: Record "Price Asset"; PriceLineFilters: Record "Price Line Filters")
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine."Price List Code" := ToPriceListHeader.Code;
        PriceListLine."Line No." := 0; // autoincrement
        ToPriceListHeader."Allow Updating Defaults" := false; // to copy defaults
        PriceListLine.CopyFrom(ToPriceListHeader);
        PriceListLine."Amount Type" := "Price Amount Type"::Price;
        PriceListLine.CopyFrom(PriceAsset);
        PriceListLine.Validate("Minimum Quantity", PriceLineFilters."Minimum Quantity");
        AdjustAmount(PriceAsset."Unit Price", PriceLineFilters);
        case ToPriceListHeader."Price Type" of
            "Price Type"::Sale:
                PriceListLine.Validate("Unit Price", PriceAsset."Unit Price");
            "Price Type"::Purchase:
                begin
                    PriceListLine.Validate("Direct Unit Cost", PriceAsset."Unit Price");
                    AdjustAmount(PriceAsset."Unit Price 2", PriceLineFilters);
                    PriceListLine.Validate("Unit Cost", PriceAsset."Unit Price 2");
                end;
        end;
        if PriceLineFilters.Worksheet then
            InsertWorksheetLine(ToPriceListHeader, PriceListLine)
        else
            PriceListLine.Insert(true);
    end;

    local procedure AdjustAmount(var Price: Decimal; PriceLineFilters: Record "Price Line Filters")
    var
        NewPrice: Decimal;
    begin
        if Price = 0 then
            exit;

        NewPrice := ConvertCurrency(Price, PriceLineFilters);
        NewPrice := NewPrice * PriceLineFilters."Adjustment Factor";

        NewPrice := Round(NewPrice, PriceLineFilters."Amount Rounding Precision");

        Price := NewPrice;
    end;


    local procedure InsertWorksheetLine(var ToPriceListHeader: Record "Price List Header"; var PriceListLine: Record "Price List Line")
    var
        PriceWorksheetLine: Record "Price Worksheet Line";
    begin
        PriceWorksheetLine.TransferFields(PriceListLine);
        PriceWorksheetLine."Line No." := 0;
        PriceWorksheetLine."Source Group" := ToPriceListHeader."Source Group";
        PriceWorksheetLine.Insert(true);
    end;

    local procedure ConvertCurrency(Price: Decimal; PriceLineFilters: Record "Price Line Filters") NewPrice: Decimal;
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        NewPrice := Price;
        if PriceLineFilters."From Currency Code" <> PriceLineFilters."To Currency Code" then
            if PriceLineFilters."From Currency Code" = '' then
                NewPrice :=
                    Round(
                        CurrExchRate.ExchangeAmtLCYToFCY(
                            PriceLineFilters."Exchange Rate Date", PriceLineFilters."To Currency Code", Price,
                            CurrExchRate.ExchangeRate(PriceLineFilters."Exchange Rate Date", PriceLineFilters."To Currency Code")),
                        PriceLineFilters."Amount Rounding Precision")
            else
                if PriceLineFilters."To Currency Code" = '' then
                    NewPrice :=
                        Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                                PriceLineFilters."Exchange Rate Date", PriceLineFilters."From Currency Code", Price,
                                CurrExchRate.ExchangeRate(PriceLineFilters."Exchange Rate Date", PriceLineFilters."From Currency Code")),
                            PriceLineFilters."Amount Rounding Precision")
                else
                    NewPrice :=
                        Round(
                            CurrExchRate.ExchangeAmtFCYToFCY(
                                PriceLineFilters."Exchange Rate Date",
                                PriceLineFilters."From Currency Code", PriceLineFilters."To Currency Code",
                                Price),
                            PriceLineFilters."Amount Rounding Precision");
    end;

}