import { Injector, NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { OpPrincipalComponent } from './principal.component';
import { OpPrincipalListComponent } from './principal-list.component';
import { PrincipalRendererService } from './principal-renderer.service';
import { registerCustomElement } from 'core-app/shared/helpers/angular/custom-elements.helper';
import {
  OpBasicSingleDatePickerComponent
} from 'core-app/shared/components/datepicker/basic-single-date-picker/basic-single-date-picker.component';
import {
  OpBasicRangeDatePickerComponent
} from 'core-app/shared/components/datepicker/basic-range-date-picker/basic-range-date-picker.component';

@NgModule({
  imports: [
    CommonModule,
  ],
  exports: [
    OpPrincipalComponent,
    OpPrincipalListComponent,
  ],
  providers: [
    PrincipalRendererService,
  ],
  declarations: [
    OpPrincipalComponent,
    OpPrincipalListComponent,
  ],
})
export class OpenprojectPrincipalRenderingModule {
  constructor(readonly injector:Injector) {
    registerCustomElement('opce-principal', OpPrincipalComponent, { injector });
  }
}
