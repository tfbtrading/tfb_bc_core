table 50123 "TFB Picture Entity"
{
    Caption = 'Custom Picture Entity';
    TableType = Temporary;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; Width; Integer)
        {
            Caption = 'Width';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; Height; Integer)
        {
            Caption = 'Height';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Mime Type"; Text[100])
        {
            Caption = 'Mime Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; Content; BLOB)
        {
            Caption = 'Content';
            DataClassification = SystemMetadata;
        }
        field(21; "Parent Type"; Enum "TFB Custom Picture Parent Type")
        {
            Caption = 'Parent Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        IdNotProvidedErr: Label 'You must specify a resource ID to get the picture.', Locked = true;
        RequestedRecordDoesNotExistErr: Label 'No resource with the specified ID exists.', Locked = true;
        RequestedRecordIsNotSupportedErr: Label 'Images are not supported for requested entity - %1.', Locked = true;
        EntityNotSupportedErr: Label 'Given parent type is not supported.';
        MultipleParentsFoundErr: Label 'Multiple parents have been found for the specified criteria.';
        MediaExtensionWithNumNameTxt: Label '%1 %2.%3', Locked = true;
        MediaExtensionWithNumFullNameTxt: Label '%1 %2 %3.%4', Locked = true;




    procedure LoadDataWithParentType(IdFilter: Text; ParentType: Enum "Picture Entity Parent Type")
    var
        MediaID: Guid;
    begin
        Id := IdFilter;
        "Parent Type" := ParentType;
        MediaID := GetMediaIDWithParentType(Id, ParentType);
        SetValuesFromMediaID(MediaID);
    end;



    procedure SavePictureWithParentType()
    var

        LotNoInfo: Record "Lot No. Information";
        GenericItem: Record "TFB Generic Item";
        ImageInStream: InStream;
    begin
        Content.CreateInStream(ImageInStream);

        case "Parent Type" of
            "Parent Type"::Sample:
                if LotNoInfo.GetBySystemId(Id) then begin
                    Clear(LotNoInfo."TFB Sample Picture");
                    LotNoInfo."TFB Sample Picture".ImportStream(ImageInStream, GetDefaultMediaDescription(LotNoInfo));
                    LotNoInfo."TFB Sample Picture Exists" := true;
                    LotNoInfo.Modify(true);
                end;
            "Parent Type"::GenericItem:
                if GenericItem.GetBySystemId(Id) then begin
                    Clear(GenericItem.Picture);
                    GenericItem.Picture.ImportStream(ImageInStream, GetDefaultMediaDescription(LotNoInfo));
                    GenericItem.Modify(true);
                end;
            else
                Error(EntityNotSupportedErr);
        end;

        LoadDataWithParentType(Format(Id), "Parent Type");
    end;



    procedure DeletePictureWithParentType()
    var

        LotNoInfo: Record "Lot No. Information";
        GenericItem: Record "TFB Generic Item";
        TempId: Guid;
        TempParentType: Enum "TFB Custom Picture Parent Type";
    begin
        case "Parent Type" of
            "Parent Type"::Sample:
                if LotNoInfo.GetBySystemId(Id) then begin
                    Clear(LotNoInfo."TFB Sample Picture");
                    LotNoInfo."TFB Sample Picture Exists" := false;
                    LotNoInfo.Modify(true);
                end;
            "Parent Type"::GenericItem:
                if GenericItem.GetBySystemId(Id) then begin
                    Clear(GenericItem.Picture);
                    GenericItem.Modify(true);
                end;
            else
                Error(EntityNotSupportedErr);
        end;

        TempId := Id;
        TempParentType := "Parent Type";
        Clear(Rec);
        Id := TempId;
        "Parent Type" := TempParentType;
    end;

    local procedure GetMediaIDWithParentType(ParentId: Guid; ParentType: Enum "TFB Custom Picture Parent Type"): Guid
    var

        LotNoInfo: Record "Lot No. Information";
        GenericItem: Record "TFB Generic Item";
        MediaID: Guid;
    begin
        case ParentType of
            "Parent Type"::Sample:
                if LotNoInfo.GetBySystemId(ParentId) then
                    if LotNoInfo."TFB Sample Picture".Count > 0 then
                        MediaID := LotNoInfo."TFB Sample Picture".Item(1);
            "Parent Type"::GenericItem:
                if GenericItem.GetBySystemId(ParentId) then
                    if GenericItem.Picture.Count > 0 then
                        MediaID := GenericItem.Picture.Item(1);
            else
                Error(EntityNotSupportedErr);
        end;

        exit(MediaID);
    end;


    local procedure GetRecordRefFromFilter(IDFilter: Text; var ParentRecordRef: RecordRef): Boolean
    var

        LotNoInfo: Record "Lot No. Information";
        GenericItem: Record "TFB Generic Item";
        RecordFound: Boolean;
    begin
        LotNoInfo.SetFilter(SystemId, IDFilter);
        if LotNoInfo.FindFirst() then begin
            ParentRecordRef.GetTable(LotNoInfo);
            RecordFound := true;
        end;

        GenericItem.SetFilter(SystemId, IDFilter);
        if not GenericItem.IsEmpty() then begin
            ParentRecordRef.GetTable(LotNoInfo);
            RecordFound := true;
        end;

        OnAfterGetRecordRefFromFilter(IDFilter, ParentRecordRef, RecordFound);
        exit(RecordFound);
    end;

    local procedure SetValuesFromMediaID(MediaID: Guid)
    var
        TenantMedia: Record "Tenant Media";
    begin
        // TODO: This code should be replaced once we get a proper platform support
        // We should not build dependencies to TenantMedia table
        if IsNullGuid(MediaID) then
            exit;

        TenantMedia.SetAutoCalcFields(Content);
        if not TenantMedia.Get(MediaID) then
            exit;

        "Mime Type" := TenantMedia."Mime Type";
        Width := TenantMedia.Width;
        Height := TenantMedia.Height;

        Content := TenantMedia.Content;
    end;

   

    local procedure ThrowEntityNotSupportedError(TableID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableID);
        if AllObjWithCaption.FindFirst() then;
        Error(RequestedRecordIsNotSupportedErr, AllObjWithCaption."Object Caption");
    end;

    procedure GetDefaultMediaDescription(ParentRecord: Variant): Text
    var
        LotNoInfo: Record "Lot No. Information";
        GenericItem: Record "TFB Generic Item";
        ParentRecordRef: RecordRef;
        MediaDescription: Text;
        IsHandled: Boolean;
    begin
        ParentRecordRef.GetTable(ParentRecord);

        case ParentRecordRef.Number of
            DATABASE::"Lot No. Information":
                begin
                    ParentRecordRef.SetTable(LotNoInfo);
                    MediaDescription := StrSubstNo(MediaExtensionWithNumNameTxt, LotNoInfo."Item No.", LotNoInfo."Lot No.", GetDefaultExtension());
                end;
            DATABASE::"TFB Generic Item":
                begin
                    ParentRecordRef.SetTable(GenericItem);
                    MediaDescription := StrSubstNo(MediaExtensionWithNumNameTxt, GenericItem.Description, GenericItem."Item Category Code", GetDefaultExtension());
                end;


            else begin
                IsHandled := false;
                OnGetDefaultMediaDescriptionElseCase(ParentRecordRef, MediaDescription, IsHandled);
                if not IsHandled then
                    exit('');
            end;
        end;

        exit(MediaDescription);
    end;

    procedure GetDefaultExtension(): Text
    begin
        exit('jpg');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetRecordRefFromFilter(IDFilter: Text; var ParentRecordRef: RecordRef; var RecordFound: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnGetDefaultMediaDescriptionElseCase(ParentRecordRef: RecordRef; var MediaDescription: Text; var IsHandled: Boolean)
    begin
    end;


}
