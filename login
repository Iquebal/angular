<toaster-container></toaster-container>
<app-progress-line *ngIf="isRequesting"></app-progress-line>
<app-error-message *ngIf="response && response.error">
  {{response.error.message}}
</app-error-message>
<div class="container-login">
  <div class="wrap-login">
    <form>
      <div class="login-header">
        <span>
          Welcome
        </span>
        <p>
            Sign in to continue
        </p>
      </div>

      <div class="form-group material-input">
        <input type="text" class="app-login-form-email" material-input name="email" [(ngModel)]="form.email">
        <span class="focus-input" data-placeholder="Email"></span>
        <span class="error-message" *ngIf="error(response, 'email')">{{error(response, 'email')}}</span>

      </div>

      <div class="form-group material-input">
        <span class="btn-show-pass" (click)="togglePassword();">
          <i [ngClass]="{'icon-visibility_off': passwordVisibilty, 'icon-visibility': (!passwordVisibilty)}"></i>
        </span>
        <input class="app-login-form-password" [type]="passwordVisibilty ? 'text' : 'password'" material-input name="password" [(ngModel)]="form.password">
        <span class="focus-input" data-placeholder="Password"></span>
        <span class="error-message" *ngIf="error(response, 'password')">{{error(response, 'password')}}</span>

      </div>

      <div class="form-group login-button">
        <button class="btn btn-primary app-login-form-submit" (click)="login($event);">
          Login
        </button>
      </div>
    </form>
  </div>
</div>

#### E:\project\SenseAble\25may\24may\src\app\ng5-basic\authentication\login-form\login-form.component.ts ######
import { Component, OnInit } from '@angular/core';
import { IUserForm } from '../shared';
import { GetNetworkError, error, GetUrl } from '@app/common';
import { Router } from '@angular/router';
import { IResponse } from 'response-type';
import { HttpClient } from '@angular/common/http';
import { UserService } from '@app/services/user.service';
import { environment } from '../../../../environments/environment';
import {HttpParams} from "@angular/common/http";

@Component({
  selector: 'app-login-form',
  templateUrl: './login-form.component.html',
  styleUrls: ['./login-form.component.scss']
})
export class LoginFormComponent implements OnInit {
  public isRequesting = false;
  public url = GetUrl('user/signin');
  public response: IResponse<any> = null;
  public error = error;
  public form: IUserForm = {
    email: '',
    password: ''
  };
  public message = '';
  public passwordVisibilty = false;

  constructor(
    private router: Router,
    private http: HttpClient,
    private user: UserService,
  ) { }

  ngOnInit() {
    this.user.Revoke();
    window.sessionStorage.removeItem('token');
   /* if (environment.github && this.user.IsFirst) {
      this.user.IsFirst = false;
      this.signinHttp({
        email: 'test@test.com',
        password: '123321'
      });
    }*/
  }

  public async login (e) {
    e.preventDefault();
    this.isRequesting = true;
    this.signinHttp(this.form);
  }

  public togglePassword() {
    this.passwordVisibilty = this.passwordVisibilty ? false : true;
  }

  public onSigninSuccess (response) {
    this.user.SetUser(response.loginId);
    this.user.SetToken(response.token);
    this.router.navigateByUrl('/index');
  }

  private signinHttp (data: IUserForm) {
    window.scroll(0, 0);
    console.log(JSON.stringify(data.email)+ "data");
     /* const headers = {
      'Authorization': 'Basic ' + btoa('testjwtclientid:XY7kmzoNzl100'),
      'Content-type': 'application/x-www-form-urlencoded'
    }  */
   
    const headers = {
      'referer': 'http://coolsense.senseable.co.in:3000/'
    } 
    JSON.stringify(headers);
    console.log(JSON.stringify(headers)+ "headers");
    /* const body = new HttpParams()
    .set('username', data.email)
    .set('password', data.password)
    .set('grant_type', 'password');
    JSON.stringify(body) */
   
    const body = new HttpParams()
    .set('username', data.email)
    .set('password', data.password);
    JSON.stringify(body)

   
    //this.http.post('http://localhost:8080/' + 'oauth/token', body, {headers}).subscribe(
    this.http.post('http://localhost:8080/UserManagementApp/' + 'login', { username: data.email, password: data.password }).subscribe(
      (response) => {
        console.log("response: " + JSON.stringify(response));
        let tokens = response;
        let tokenGet = tokens['token'];
        console.log("tokenGet: " + tokenGet);
       // window.sessionStorage.setItem('token', JSON.stringify(response));
        window.sessionStorage.setItem('token', tokenGet);
        console.log(window.sessionStorage.getItem('token') + " Token store");   
        this.response = response;
        if (this.response!=null) {
          this.onSigninSuccess(response);
        }
        this.isRequesting = false;
      },
      (response) => {
        this.isRequesting = false;
        if (response.name === 'HttpErrorResponse') {
          this.response = GetNetworkError();
          return false;
        }
        this.response = response;
      }
    );
  }
}
