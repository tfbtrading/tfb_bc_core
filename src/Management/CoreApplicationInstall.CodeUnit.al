codeunit 50126 "TFB Core Application Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()

    begin
        AddGuidedExperienceItems();

    end;

    local procedure AddGuidedExperienceItems()

    var
        GuidedExperience: CodeUnit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        AssistedSetupDescriptionTxt: label 'Setup Core TFB';
        AssistedSetupShortTitleTxt: label 'TFB Core';
        AssistedSetupTitleTxt: label 'TFB Core Extension Setup';
    begin

        GuidedExperience.InsertAssistedSetup(AssistedSetupTitleTxt, AssistedSetupShortTitleTxt, AssistedSetupDescriptionTxt, 10, ObjectType::Page, Page::"TFB Core Setup", AssistedSetupGroup::GettingStarted, '', VideoCategory::GettingStarted, '');

    end;
}