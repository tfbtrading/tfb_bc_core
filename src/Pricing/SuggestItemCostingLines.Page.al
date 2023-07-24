page 50157 "TFB Suggest Item Costing Lines"
{
    Caption = 'Price Lines';
    PageType = StandardDialog;
    SourceTable = "TFB Item Costing Filters";
    DataCaptionExpression = DataCaption;
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            group(All)
            {
                ShowCaption = false;
                group(Line)
                {
                    ShowCaption = false;

                    field("Price List Code"; Rec."Price List Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Compare to Price List';
                        ToolTip = 'Specifies the price list code to compare against item costing    ';
                        TableRelation = "Price List Header" where("Price Type" = const(Sale));



                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Product Filter"; GetReadableProductFilter())
                    {
                        ApplicationArea = All;
                        Caption = 'Costing Line Filter';
                        ToolTip = 'Specifies the filter for item costing fields';
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            Rec.EditAssetFilter();
                            CurrPage.SaveRecord();
                        end;
                    }

                    field("Close Existing Lines"; Rec."Close Existing Lines")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Close existing pricing lines';

                        ToolTip = 'Specifies if the suggested lines will also close existing lines in previous price list with yesterdays date';

                    }
                }

            }
        }
    }


    trigger OnOpenPage()
    var

    begin

        Rec.Insert();


        DataCaption := DataCaptionCopyLbl

    end;

    var
        TempDefaultsPriceListHeader: Record "Price List Header" temporary;
        Defaults: Text;
        DataCaption: Text;
        DataCaptionCopyLbl: Label 'Suggest based on item costing';

        DefaultsLbl: Label '%1 = %2; ', Locked = true;

    procedure GetDefaults(var PriceListHeader: Record "Price List Header")
    begin
        PriceListHeader := TempDefaultsPriceListHeader;
    end;

    local procedure GetDefaults() Result: Text
    begin
        Result := GetDefaults(TempDefaultsPriceListHeader.FieldCaption("Source Type"), Format(TempDefaultsPriceListHeader."Source Type"), true);
        Result += GetDefaults(TempDefaultsPriceListHeader.FieldCaption("Parent Source No."), TempDefaultsPriceListHeader."Parent Source No.", false);
        Result += GetDefaults(TempDefaultsPriceListHeader.FieldCaption("Source No."), TempDefaultsPriceListHeader."Source No.", false);
        Result += GetDefaults(TempDefaultsPriceListHeader.FieldCaption("Currency Code"), TempDefaultsPriceListHeader."Currency Code", false);
        Result += GetDefaults(TempDefaultsPriceListHeader.FieldCaption("Starting Date"), format(TempDefaultsPriceListHeader."Starting Date"), false);
        Result += GetDefaults(TempDefaultsPriceListHeader.FieldCaption("Ending Date"), format(TempDefaultsPriceListHeader."Ending Date"), false);
    end;

    local procedure GetDefaults(FldName: Text; FldValue: Text; ShowBlank: Boolean): Text;
    begin
        if ShowBlank or (FldValue <> '') then
            exit(StrSubstNo(DefaultsLbl, FldName, FldValue))
    end;

    procedure SetDefaults(PriceListHeader: Record "Price List Header")
    begin
        TempDefaultsPriceListHeader := PriceListHeader;
        Defaults := GetDefaults();
    end;

    local procedure GetReadableProductFilter() Result: Text
    var
        RecRef: RecordRef;
    begin
        if Rec."Product Filter" = '' then
            exit('');
        RecRef.Open(Database::Item);
        RecRef.SetView(Rec."Product Filter");
        Result := RecRef.GetView(true);
        RecRef.Close();
    end;

}