import { Controller, Get, Param, NotFoundException, HttpCode, HttpStatus, UseGuards, Req } from '@nestjs/common';
import { Request } from 'express';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

// Definicja interfejsu dla rozszerzonego obiektu Request
interface RequestWithUser extends Request {
  user: {
    userId: string;
    username: string;
  };
}

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // Pobieranie profilu zalogowanego użytkownika - bardziej specyficzna trasa najpierw
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async getCurrentUserProfile(@Req() req: RequestWithUser) {
    const user = await this.usersService.findById(req.user.userId);
    return {
      success: true,
      data: { user: { username: user.username, email: user.email } },
      statusCode: HttpStatus.OK,
    };
  }

  // Publiczny profil użytkownika - bardziej ogólna trasa na końcu
  @Get(':username')
  @HttpCode(HttpStatus.OK)
  async getProfile(@Param('username') username: string) {
    try {
      const profile = await this.usersService.getPublicProfile(username);
      return profile;
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw error;
    }
  }
}

