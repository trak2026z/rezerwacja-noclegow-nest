import { Body, Controller, Post, Get, Param, HttpCode, HttpStatus, ConflictException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly usersService: UsersService
  ) {}

  // Rejestracja
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() createUserDto: CreateUserDto) {
    try {
      return await this.authService.register(createUserDto);
    } catch (error) {
      if (error instanceof ConflictException) {
        throw error; // Przekazujemy dalej, aby filtr wyjątków mógł go obsłużyć
      }
      throw error;
    }
  }

  // Logowanie
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  // Sprawdzanie dostępności emaila
  @Get('checkEmail/:email')
  async checkEmail(@Param('email') email: string) {
    const taken = await this.usersService.isEmailTaken(email);
    if (taken) {
      return {
        success: false,
        message: 'Email is already taken',
        statusCode: HttpStatus.CONFLICT,
      };
    }
    return {
      success: true,
      message: 'Email is available',
      statusCode: HttpStatus.OK,
    };
  }

  // Sprawdzanie dostępności nazwy użytkownika
  @Get('checkUsername/:username')
  async checkUsername(@Param('username') username: string) {
    const taken = await this.usersService.isUsernameTaken(username);
    if (taken) {
      return {
        success: false,
        message: 'Username is already taken',
        statusCode: HttpStatus.CONFLICT,
      };
    }
    return {
      success: true,
      message: 'Username is available',
      statusCode: HttpStatus.OK,
    };
  }
}
